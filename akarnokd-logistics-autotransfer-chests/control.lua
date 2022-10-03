script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
}, function(event)
    handleEntityPlaced(event.created_entity)
end)

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_pre_player_mined_item,
    defines.events.on_robot_pre_mined,
    defines.events.script_raised_destroy
}, function(event)
    handleEntityRemoved(event.entity)
end)

script.on_event(defines.events.on_tick, function(event)
    handleTick()
end)

local supportedEntityTypes = {
    ["nuclear-reactor"] = true,
    ["boiler"] = true
}

function isSupported(entity)
    return entity.prototype.mining_speed or entity.prototype.crafting_speed or entity.prototype.researching_speed
        or supportedEntityTypes[entity.prototype.name]
end

function handleEntityPlaced(entity)
    if entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active" then

        local state = ensureGlobal()
        local chestData = {
            chest = entity,
            neighbors = { }
        }
        chestData.neighbors = getNearbyMachines(entity)
        
        state.providerChests[#state.providerChests + 1] = chestData

    elseif entity.name == "akarnokd-latc-requester" then
        
        local state = ensureGlobal()
        local chestData = {
            chest = entity,
            neighbors = { }
        }
        chestData.neighbors = getNearbyMachines(entity)
        state.requesterChests[#state.requesterChests + 1] = chestData
        
    elseif isSupported(entity) then
        --log("AutoTransfer to/from " .. entity.name)
        local state = ensureGlobal()
        
        for _, item in pairs(getNearbyChests(entity)) do
            for _, ithChest in pairs(state.providerChests) do
                if ithChest.chest == item then
                    ithChest.neighbors[#ithChest.neighbors + 1] = entity
                end
            end
            for i, ithChest in pairs(state.requesterChests) do
                if ithChest.chest == item then
                    ithChest.neighbors[#ithChest.neighbors + 1] = entity
                end
            end
        end
    end
end

function handleEntityRemoved(entity)
    if entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active" then
        local state = ensureGlobal()
        for i, ithChest in pairs(state.providerChests) do
            if ithChest.chest == entity then
                state.providerChests[i] = nil
            end
        end
    elseif entity.name == "akarnokd-latc-requester" then
        local state = ensureGlobal()
        for i, ithChest in pairs(state.requesterChests) do
            if ithChest.chest == entity then
                state.requesterChests[i] = nil
            end
        end
    elseif isSupported(entity) then
        local state = ensureGlobal()
        for i, ithChest in pairs(state.providerChests) do
            for j, jthEntry in pairs(ithChest.neighbors) do
                if jthEntry == entity then
                    ithChest.neighbors[j] = nil
                end
            end
        end
        for i, ithChest in pairs(state.requesterChests) do
            for j, jthEntry in pairs(ithChest.neighbors) do
                if jthEntry == entity then
                    ithChest.neighbors[j] = nil
                end
            end
        end
    end
end

function ensureGlobal()
    if not global.akarnokdLatc then
        global.akarnokdLatc = { }
        global.akarnokdLatc.providerChests = { }
        global.akarnokdLatc.requesterChests = { }
    end
    return global.akarnokdLatc
end

function getNearbyMachines(entity)
    local nextEntities = entity.surface.find_entities_filtered(
                {
                    area =
                    {
                        {
                            x = entity.bounding_box.left_top.x - 1,
                            y = entity.bounding_box.left_top.y - 1
                        },
                        {
                            x = entity.bounding_box.right_bottom.x + 1,
                            y = entity.bounding_box.right_bottom.y + 1
                        }
                    },
                })
    local result = { }
    
    for _, item in pairs(nextEntities) do
        if isSupported(item) then
            result[#result + 1] = item
        end
    end
    
    return result
end

function getNearbyChests(entity)
    local nextEntities = entity.surface.find_entities_filtered(
                {
                    area =
                    {
                        {
                            x = entity.bounding_box.left_top.x - 1,
                            y = entity.bounding_box.left_top.y - 1
                        },
                        {
                            x = entity.bounding_box.right_bottom.x + 1,
                            y = entity.bounding_box.right_bottom.y + 1
                        }
                    },
                    name = { "akarnokd-latc-passive", "akarnokd-latc-active", "akarnokd-latc-requester"}
                })
    return nextEntities
end

function findOutputInventories(source)
    local result = { }
    local inv = source.get_inventory(defines.inventory.furnace_result)
    if inv then 
        result[#result + 1] = inv
    end
    inv = source.get_inventory(defines.inventory.assembling_machine_output)
    if inv then 
        result[#result + 1] = inv
    end
    inv = source.get_inventory(defines.inventory.burnt_result)
    if inv then 
        result[#result + 1] = inv
    end
    return result
end

function transfer(sourceInventory, destinationInventory, recipe, limit, tag)
    if not destinationInventory then return end
    
    local content = sourceInventory.get_contents()
    for name, count in pairs(content) do
        local toInsert = count
        if recipe then
            for _, ingredient in pairs(recipe.ingredients) do
                if ingredient.name == name then
                    if limit then
                        limit = math.min(limit, ingredient.amount + 1)
                    else
                        limit = ingredient.amount + 1
                    end
                    break
                end
            end
        end

        if limit then
            local currentCount = destinationInventory.get_item_count(name)
            if currentCount + toInsert > limit then
               toInsert = limit - currentCount
            end
        end
        if toInsert > 0 then
            inserted = destinationInventory.insert({ name = name, count = toInsert })
            if inserted > 0 then
                --log(tag .. " | Transfer " .. name .. " x " .. toInsert .. " (" .. inserted .. ")")
                sourceInventory.remove({ name = name, count = inserted })
            end
        end
    end
end

function canHaveRecipe(entity)
    return entity.type == "assembling-machine"
        or entity.type == "furnace"
        or entity.type == "rocket-silo"
end

function handleTick()
    local state = ensureGlobal()

    for i, ithChest in pairs(state.providerChests) do
        if ithChest.chest.valid then
            local inv = ithChest.chest.get_inventory(defines.inventory.chest)
            for j, source in pairs(ithChest.neighbors) do
                local outputs = findOutputInventories(source)
                for _, output in pairs(outputs) do
                    transfer(output, inv, nil, nil, "outputs")
                end
            end
        else
            state.providerChests[i] = nil
        end
    end
    for i, ithChest in pairs(state.requesterChests) do
        if ithChest.chest.valid then
            local inv = ithChest.chest.get_inventory(defines.inventory.chest)
            for j, dest in pairs(ithChest.neighbors) do
                local rec = nil
                if canHaveRecipe(dest) then
                    rec = dest.get_recipe()
                    transfer(inv, dest.get_inventory(defines.inventory.furnace_source), rec, 1000, "furnace_source")
                    transfer(inv, dest.get_inventory(defines.inventory.assembling_machine_input), rec, 1000, "assembling_machine_input")
                    transfer(inv, dest.get_inventory(defines.inventory.rocket_silo_input), rec, 1000, "rocket_silo_input")
                else
                    transfer(inv, dest.get_inventory(defines.inventory.lab_input), nil, 5, "lab_input")
                end
                
                transfer(inv, dest.get_inventory(defines.inventory.fuel), nil, 5, "fuel")
                
            end
        else
            state.requesterChests[i] = nil
        end
    end
end
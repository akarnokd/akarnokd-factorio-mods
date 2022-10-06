local supportedEntityTypes = {
    ["nuclear-reactor"] = true,
    ["boiler"] = true
}

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

function getOrCreateProviderGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-frame"]
    if not frame or not frame.valid then
        local anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-frame"}
        
        frame.add{type="label", caption={"akarnokd-latc-gui.limit"}}
        frame.add{type="textfield", name="akarnokd-latc-gui-textfield", text="0", numeric=true, allow_decimal=false, allow_negative=false}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-unlimited", caption={"akarnokd-latc-gui.unlimited"}}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set10", caption="10"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set100", caption="100"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set1000", caption="1000"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set10000", caption="10000"}
        --log("akarnokd-latc-gui-frame created")
    end
    return frame
end

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)
    if event.entity then
        --log("GUI for " .. event.entity.name)
        local frame = getOrCreateProviderGui(player)
        if event.entity.name == "akarnokd-latc-passive" or event.entity.name == "akarnokd-latc-active" then
            local state = ensureGlobal()
            state.currentGuiEntity = event.entity
            frame.visible = true
            local latcLimit = getLimitGui(event.entity)
            if latcLimit then
                frame["akarnokd-latc-gui-textfield"].text = tostring(latcLimit)
                log("akarnokd-latc-gui-textfield set to " .. latcLimit)
            else
                frame["akarnokd-latc-gui-textfield"].text = "0"
                log("akarnokd-latc-gui-textfield set to default 0")
            end
        else
            frame.visible = false
        end
    end    
end)

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)
    local frame = player.gui.relative["akarnokd-latc-gui-frame"]
    local state = ensureGlobal()
    local entity = state.currentGuiEntity
    
    if event.element.name == "akarnokd-latc-gui-textfield-unlimited" then
        frame["akarnokd-latc-gui-textfield"].text = "0"
        updateLimit(entity, 0)
    end
    if event.element.name == "akarnokd-latc-gui-textfield-set10" then
        frame["akarnokd-latc-gui-textfield"].text = "10"
        updateLimit(entity, 10)
    end
    if event.element.name == "akarnokd-latc-gui-textfield-set100" then
        frame["akarnokd-latc-gui-textfield"].text = "100"
        updateLimit(entity, 100)
    end
    if event.element.name == "akarnokd-latc-gui-textfield-set1000" then
        frame["akarnokd-latc-gui-textfield"].text = "1000"
        updateLimit(entity, 1000)
    end
    if event.element.name == "akarnokd-latc-gui-textfield-set10000" then
        frame["akarnokd-latc-gui-textfield"].text = "10000"
        updateLimit(entity, 10000)
    end
end)

script.on_event(defines.events.on_gui_value_changed, function(event)
    if event.element.name == "akarnokd-latc-gui-textfield" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateLimit(entity, tonumber(event.element.text))
    end
end)

function updateLimit(entity, amount)
    if entity and (entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active") then
        local state = ensureGlobal()
        state.latcLimits[entity.unit_number] = amount
        --log(entity.name .. " new limit " .. amount .. " ID " .. entity.unit_number)
    end
end

function getLimitGui(entity)
    local state = ensureGlobal()
    --log("GetLimitGUI " .. entity.name .. " ID " .. entity.unit_number)
    if entity and (entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active") then
        local v = state.latcLimits[entity.unit_number]
        --log("GetLimitGUI " .. entity.name .. " ID " .. entity.unit_number .. " Value " .. tostring(v))
        return v
    end
    return nil
end

function getLimit(entity)
    if entity and (entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active") then
        local state = ensureGlobal()
        return state.latcLimits[entity.unit_number]
    end
    return nil
end


function isSupported(entity)
    return (entity.prototype.mining_speed or entity.prototype.crafting_speed or entity.prototype.researching_speed
        or supportedEntityTypes[entity.prototype.name])
        and not entity.prototype.name == "character"
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
    if not global.akarnokdLatc.latcLimits then
        global.akarnokdLatc.latcLimits = { }
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

function transfer(sourceInventory, destinationInventory, recipe, alimit, tag)
    if not destinationInventory then return end
    
    local content = sourceInventory.get_contents()
    for name, count in pairs(content) do
        local limit = alimit
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
    local maxItems = settings.global["akarnokd-latc-max-items"].value
    local insertIfEmpty = settings.global["akarnokd-latc-insert-if-empty-output"].value

    for i, ithChest in pairs(state.providerChests) do
        if ithChest.chest.valid then
            local inv = ithChest.chest.get_inventory(defines.inventory.chest)
            local maxItemInChest = maxItems
            local latcLimit = getLimit(ithChest.chest)
            if latcLimit then
                if ithChest.latcLimit == 0 then
                    maxItemInChest = nil
                else
                    maxItemInChest = latcLimit
                end
            end
            for j, source in pairs(ithChest.neighbors) do
                local outputs = findOutputInventories(source)
                for _, output in pairs(outputs) do
                    transfer(output, inv, nil, maxItemInChest, "outputs")
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
                    
                    local doInsertAssembly = true
                    if insertIfEmpty then
                        local outputInv = dest.get_inventory(defines.inventory.assembling_machine_output)
                        if outputInv and not outputInv.is_empty() then
                            doInsertAssembly = false
                        end
                    end
                    if doInsertAssembly then
                        transfer(inv, dest.get_inventory(defines.inventory.assembling_machine_input), rec, 1000, "assembling_machine_input")
                    end
                    
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
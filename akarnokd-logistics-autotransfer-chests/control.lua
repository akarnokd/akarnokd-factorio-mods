local supportedEntityTypes = {
    ["nuclear-reactor"] = true,
    ["boiler"] = true
}

local replaceTimeout = 60

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
}, function(event)
    handleEntityPlaced(event.created_entity, event.tick, event.tags)
end)

script.on_event({
    defines.events.on_entity_died,
    defines.events.on_pre_player_mined_item,
    defines.events.on_robot_pre_mined,
    defines.events.script_raised_destroy
}, function(event)
    handleEntityRemoved(event.entity, event.tick)
end)

script.on_event(defines.events.on_tick, function(event)
    handleTick(event.tick)
end)

function getOrCreateProviderGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-frame"]
    if (not frame) or (not frame.valid) then
        local anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-frame"}
        
        frame.add{type="label", caption={"akarnokd-latc-gui.limit"}}
        frame.add{type="textfield", name="akarnokd-latc-gui-textfield", text="0", numeric=true, allow_decimal=false, allow_negative=false}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-unlimited", caption={"akarnokd-latc-gui.default"}}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set1", caption="1"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set10", caption="10"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set100", caption="100"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set1000", caption="1000"}
        frame.add{type="button", name="akarnokd-latc-gui-textfield-set10000", caption="10000"}
        --log("akarnokd-latc-gui-frame created")
    end
    return frame
end

function getOrCreateRequesterGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-provider-frame"]
    if (not frame) or (not frame.valid) then
        local anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-provider-frame"}

        local parent = frame.add{type="flow", name="akarnokd-latc-gui-provider-parent", direction="vertical"}
        
        local pastePanel = parent.add{type="flow", name="akarnokd-latc-gui-provider-paste", direction="horizontal"}

        pastePanel.add{type="label", caption={"akarnokd-latc-gui.paste"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-one", caption={"akarnokd-latc-gui.paste-one"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-five", caption={"akarnokd-latc-gui.paste-five"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-ten", caption={"akarnokd-latc-gui.paste-ten"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-hundred", caption={"akarnokd-latc-gui.paste-hundred"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-1x", caption={"akarnokd-latc-gui.paste-1x"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-5x", caption={"akarnokd-latc-gui.paste-5x"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-10x", caption={"akarnokd-latc-gui.paste-10x"}}
        pastePanel.add{type="button", name="akarnokd-latc-gui-provider-frame-100x", caption={"akarnokd-latc-gui.paste-100x"}}

        local thresholdPanel = parent.add{type="flow", name="akarnokd-latc-gui-provider-threshold", direction="horizontal"}
        thresholdPanel.add{type="checkbox", name="akarnokd-latc-gui-provider-threshold-enabled", caption={"akarnokd-latc-gui.threshold"}, state = false}
        thresholdPanel.add{type="textfield", name="akarnokd-latc-gui-provider-threshold-min", text="0", numeric=true, allow_decimal=false, allow_negative=false}
        thresholdPanel.add{type="label", caption={"akarnokd-latc-gui.upto"}}
        thresholdPanel.add{type="textfield", name="akarnokd-latc-gui-provider-threshold-max", text="1000000", numeric=true, allow_decimal=false, allow_negative=false}
        thresholdPanel.add{type="label", caption={"akarnokd-latc-gui.request"}}
        thresholdPanel.add{type="textfield", name="akarnokd-latc-gui-provider-threshold-request", text="10", numeric=true, allow_decimal=false, allow_negative=false}
    end
    return frame
end

function getOrCreateMachineGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-machine-frame"]
    if not frame or not frame.valid then
        local anchor = {gui = defines.relative_gui_type.assembling_machine_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-machine-frame"}
        frame.add{type="button", name="akarnokd-latc-gui-machine-frame-copy", caption={"akarnokd-latc-gui.copy"}}
    end
    return frame
end
function getOrCreateFurnaceGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-furnace-frame"]
    if not frame or not frame.valid then
        local anchor = {gui = defines.relative_gui_type.furnace_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-furnace-frame"}
        frame.add{type="button", name="akarnokd-latc-gui-furnace-frame-copy", caption={"akarnokd-latc-gui.copy"}}
    end
    return frame
end
function getOrCreateRocketSiloGui(player)
    local frame = player.gui.relative["akarnokd-latc-gui-rocketsilo-frame"]
    if not frame or not frame.valid then
        local anchor = {gui = defines.relative_gui_type.rocket_silo_gui, position = defines.relative_gui_position.bottom}
        frame = player.gui.relative.add{type="frame", anchor=anchor, name="akarnokd-latc-gui-rocketsilo-frame"}
        frame.add{type="button", name="akarnokd-latc-gui-rocketsilo-frame-copy", caption={"akarnokd-latc-gui.copy"}}
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
            local panel = frame
            local latcLimit = getLimitGui(event.entity)
            if latcLimit then
                panel["akarnokd-latc-gui-textfield"].text = tostring(latcLimit)
                --log("akarnokd-latc-gui-textfield set to " .. latcLimit)
            else
                panel["akarnokd-latc-gui-textfield"].text = "0"
                --log("akarnokd-latc-gui-textfield set to default 0")
            end
        else
            frame.destroy()
        end
        
        frame = getOrCreateRequesterGui(player)
        if event.entity.name == "akarnokd-latc-requester" then
            local state = ensureGlobal()
            state.currentGuiEntity = event.entity
            frame.visible = true
            local panel = frame["akarnokd-latc-gui-provider-parent"]["akarnokd-latc-gui-provider-threshold"]
            local trs = getThreshold(event.entity)
            if trs then
                panel["akarnokd-latc-gui-provider-threshold-enabled"].state = trs.enabled
                panel["akarnokd-latc-gui-provider-threshold-min"].text = tostring(trs.minValue)
                panel["akarnokd-latc-gui-provider-threshold-max"].text = tostring(trs.maxValue)
                panel["akarnokd-latc-gui-provider-threshold-request"].text = tostring(trs.request)
            else
                panel["akarnokd-latc-gui-provider-threshold-enabled"].state = false
                panel["akarnokd-latc-gui-provider-threshold-min"].text = "0"
                panel["akarnokd-latc-gui-provider-threshold-max"].text = "1000000"
                panel["akarnokd-latc-gui-provider-threshold-request"].text = "10"
            end
        else
            frame.destroy()
        end

        frame = getOrCreateFurnaceGui(player)
        if event.entity.type == "furnace" then
            local state = ensureGlobal()
            state.currentGuiEntity = event.entity
            frame.visible = true
        else
            frame.visible = false
        end
        frame = getOrCreateMachineGui(player)
        if event.entity.type == "assembling-machine" then
            local state = ensureGlobal()
            state.currentGuiEntity = event.entity
            frame.visible = true
        else
            frame.visible = false
        end
        frame = getOrCreateRocketSiloGui(player)
        if event.entity.type == "rocket-silo" then
            local state = ensureGlobal()
            state.currentGuiEntity = event.entity
            frame.visible = true
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
    if event.element.name == "akarnokd-latc-gui-textfield-set1" then
        frame["akarnokd-latc-gui-textfield"].text = "1"
        updateLimit(entity, 1)
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
    
    if state.currentGuiEntity then
        if event.element.name == "akarnokd-latc-gui-furnace-frame-copy" 
            or event.element.name == "akarnokd-latc-gui-machine-frame-copy" 
            or event.element.name == "akarnokd-latc-gui-rocketsilo-frame-copy" 
        then
            state.recipeCopyPaste = state.currentGuiEntity.get_recipe()
        end
    end
    
    if state.recipeCopyPaste and state.currentGuiEntity then
        local itemMultiplier = 0
        local itemRecipeMultiplier = 0
        if event.element.name == "akarnokd-latc-gui-provider-frame-one" then
            itemMultiplier = 1
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-five" then
            itemMultiplier = 5
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-ten" then
            itemMultiplier = 10
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-hundred" then
            itemMultiplier = 100
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-1x" then
            itemRecipeMultiplier = 1
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-5x" then
            itemRecipeMultiplier = 5
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-10x" then
            itemRecipeMultiplier = 10
        end
        if event.element.name == "akarnokd-latc-gui-provider-frame-100x" then
            itemRecipeMultiplier = 100
        end
        
        if itemMultiplier > 0 then
            local slotIdx = 1
            for _, ingredient in pairs(state.recipeCopyPaste.ingredients) do
                if ingredient.type == "item" then
                    state.currentGuiEntity.set_request_slot( { name = ingredient.name, count = itemMultiplier }, slotIdx )
                    slotIdx = slotIdx + 1
                end
            end
        elseif itemRecipeMultiplier > 0 then
            local slotIdx = 1
            for _, ingredient in pairs(state.recipeCopyPaste.ingredients) do
                if ingredient.type == "item" then
                    state.currentGuiEntity.set_request_slot( { name = ingredient.name, count = itemRecipeMultiplier * ingredient.amount }, slotIdx )
                    slotIdx = slotIdx + 1
                end
            end
        end
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name == "akarnokd-latc-gui-textfield" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateLimit(entity, tonumber(event.element.text))
    end
    if event.element.name == "akarnokd-latc-gui-provider-threshold-min" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateThreshold(entity, nil, tonumber(event.element.text), nil, nil)
    end
    if event.element.name == "akarnokd-latc-gui-provider-threshold-max" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateThreshold(entity, nil, nil, tonumber(event.element.text), nil)
    end
    if event.element.name == "akarnokd-latc-gui-provider-threshold-request" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateThreshold(entity, nil, nil, nil, tonumber(event.element.text))
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    if event.element.name == "akarnokd-latc-gui-provider-threshold-enabled" then
        local state = ensureGlobal()
        local entity = state.currentGuiEntity
        updateThreshold(entity, event.element.state, nil, nil)
    end
end)

script.on_event(defines.events.on_player_setup_blueprint, function(event)
    local player = game.get_player(event.player_index)
    local bp = player.blueprint_to_setup
    if not bp.valid_for_read then
        bp = player.cursor_stack
    end
    if bp and bp.valid then
        local bp_ents = bp.get_blueprint_entities()
        if bp_ents then
            local source = event.mapping.get()
            for i, entity in pairs(bp_ents) do
                local sourceEntity = source[entity.entity_number]
                if sourceEntity then
                    if sourceEntity.name == "akarnokd-latc-active" or sourceEntity.name == "akarnokd-latc-passive" then
                        if not entity.tags then
                            entity.tags = { }
                        end
                        local v = getLimit(sourceEntity)
                        entity.tags["latcLimit"] = v
                        log("Tagging " .. entity.entity_number .. " of " .. sourceEntity.name .. " with " .. tostring(v))
                    elseif sourceEntity.name == "akarnokd-latc-requester" then
                        local trs = getThreshold(sourceEntity)
                        if trs then
                            if not entity.tags then
                                entity.tags = { }
                            end
                            entity.tags["latcThreshold"] = trs
                            log("Tagging " .. entity.entity_number .. " of " .. sourceEntity.name .. " for " 
                                .. tostring(trs.enabled) .. ", "
                                .. tostring(trs.minValue) .. ", "
                                .. tostring(trs.maxValue) .. ", "
                                .. tostring(trs.request) .. ", "
                            )
                        end
                    end
                end
            end
            bp.set_blueprint_entities(bp_ents)
        end
    end
end)

function updateThreshold(entity, enabled, minValue, maxValue, request)
    local state = ensureGlobal()
    local trs = state.thresholds[entity.unit_number]
    if not trs then
        trs = { enabled = false, minValue = 0, maxValue = 1000000, request = 10 }
        state.thresholds[entity.unit_number] = trs
    end
    if enabled ~= nil then
        trs.enabled = enabled
    end
    if minValue then
        trs.minValue = minValue
    end
    if maxValue then
        trs.maxValue = maxValue
    end
    if request then
        trs.request = request
    end
end

function getThreshold(entity)
    local state = ensureGlobal()
    return state.thresholds[entity.unit_number]
end

function updateLimit(entity, amount)
    if entity and (entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active") then
        local state = ensureGlobal()
        state.latcLimits[entity.unit_number] = amount
        log(entity.name .. " new limit " .. tostring(amount) .. " ID " .. entity.unit_number)
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
    return (entity.prototype.mining_speed 
            or entity.prototype.crafting_speed 
            or entity.prototype.researching_speed
            or supportedEntityTypes[entity.prototype.name]
        )
        and entity.prototype.name ~= "character"
end

function handleEntityPlaced(entity, tick, tags)
    if entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active" then

        local state = ensureGlobal()
        local chestData = {
            chest = entity,
            neighbors = { }
        }
        chestData.neighbors = getNearbyMachines(entity)
        
        state.providerChests[#state.providerChests + 1] = chestData
        
        local posStr = positionToString(entity.bounding_box.left_top)
        local prev = state.replaceProviders[posStr]
        if prev then
            --log("Found old provider at " .. posStr .. " Old tick " .. prev.tick .. " now " .. tick)
            if prev.tick + replaceTimeout >= tick then
                updateLimit(entity, prev.amount)
            end
            state.replaceProviders[posStr] = nil
        end
        
        local tg = tags or entity.tags
        log("Tags " .. tostring(tg))
        if tg and tg.latcLimit then
            updateLimit(entity, tg.latcLimit)
        end

    elseif entity.name == "akarnokd-latc-requester" then
        
        local state = ensureGlobal()
        local chestData = {
            chest = entity,
            neighbors = { }
        }
        chestData.neighbors = getNearbyMachines(entity)
        state.requesterChests[#state.requesterChests + 1] = chestData
        
        local tg = tags or entity.tags
        log("Tags " .. tostring(tg))
        if tg and tg.latcThreshold then
            updateThreshold(entity, tg.latcThreshold.enabled, tg.latcThreshold.minValue, tg.latcThreshold.maxValue, tg.latcThreshold.request)
        end
        
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

function handleEntityRemoved(entity, tick)
    if entity.name == "akarnokd-latc-passive" or entity.name == "akarnokd-latc-active" then
        local state = ensureGlobal()
        for i, ithChest in pairs(state.providerChests) do
            if ithChest.chest == entity then
            
                local posStr = positionToString(entity.bounding_box.left_top)
                state.replaceProviders[posStr] = {
                    tick = tick,
                    amount = state.latcLimits[entity.unit_number]
                }
                --log("Removed provider at " .. posStr)
                
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

function positionToString(pos)
    return pos.x .. ":" .. pos.y
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
    if not global.akarnokdLatc.thresholds then
        global.akarnokdLatc.thresholds = { }
    end
    if not global.akarnokdLatc.replaceProviders then
        global.akarnokdLatc.replaceProviders = { }
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

function transfer(sourceInventory, destinationInventory, recipe, alimit, tag, factor)
    if not destinationInventory then return end

    local limits = { }
    if recipe then
        for _, ingredient in pairs(recipe.ingredients) do
            if alimit then
                limits[ingredient.name] = math.min(alimit, factor * ingredient.amount + 1)
            else
                limits[ingredient.name] = factor * ingredient.amount + 1
            end
        end
    end
    
    local content = sourceInventory.get_contents()
    for name, count in pairs(content) do
        local limit = limits[name] or alimit
        local toInsert = count

        if limit then
            local currentCount = destinationInventory.get_item_count(name)
            if currentCount + toInsert > limit then
               toInsert = limit - currentCount
            end
        end
        if toInsert > 0 then
            inserted = destinationInventory.insert({ name = name, count = toInsert })
            if inserted > 0 then
                --log(tag .. " | Transfer " .. name .. " x " .. toInsert .. " (" .. inserted .. ") " .. tag)
                sourceInventory.remove({ name = name, count = inserted })
            end
        end
    end
end

function handleThresholdChests(state, ithChest)
    -- handle threshold-based requesting
    local trs = state.thresholds[ithChest.chest.unit_number]
    if trs and trs.enabled and ithChest.chest.logistic_network then
        for ri = 1, ithChest.chest.request_slot_count do
            local rs = ithChest.chest.get_request_slot(ri)
            if rs then
                local num = ithChest.chest.logistic_network.get_item_count(rs.name, "providers")
                if num >= trs.minValue and num <= trs.maxValue then
                    if rs.count ~= trs.request then
                        ithChest.chest.set_request_slot({ name = rs.name, count = trs.request }, ri)
                    end
                else
                    if rs.count ~= 0 then
                        ithChest.chest.set_request_slot({ name = rs.name, count = 0 }, ri ) 
                    end
                end
            end
        end
    end
end

function invEmpty(inv)
    local slots = #inv
    if slots > 0 then
        return inv[1].count == 0
    end
    return true
end

function handleTick(tick)

    local state = ensureGlobal()
    local maxItems = settings.global["akarnokd-latc-max-items"].value
    local recipeFactor = settings.global["akarnokd-latc-recipe-factor"].value or 1
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
                if source.valid then
                    local outputs = findOutputInventories(source)
                    for _, output in pairs(outputs) do
                        transfer(output, inv, nil, maxItemInChest, "outputs", 1)
                    end
                else
                    ithChest.neighbors[j] = nil
                    break
                end
            end
        else
            state.providerChests[i] = nil
            break
        end
    end

    for i, ithChest in pairs(state.requesterChests) do
        if ithChest.chest.valid then
        
            handleThresholdChests(state, ithChest)
            
            -- handle inserting into neighbors
            local inv = ithChest.chest.get_inventory(defines.inventory.chest)
            for j, dest in pairs(ithChest.neighbors) do
                if dest.valid then
                    if dest.type == "assembling-machine" then
                        local outputInv = dest.get_inventory(defines.inventory.assembling_machine_output)
                        if (not insertIfEmpty) or (not outputInv) or invEmpty(outputInv) then
                            transfer(inv, dest.get_inventory(defines.inventory.assembling_machine_input), dest.get_recipe(), 1000, "assembling_machine_input", recipeFactor)
                        end
                    elseif dest.type == "furnace" then
                        local outputInv = dest.get_inventory(defines.inventory.furnace_result)
                        if (not insertIfEmpty) or (not outputInv) or invEmpty(outputInv) then
                            transfer(inv, dest.get_inventory(defines.inventory.furnace_source), dest.get_recipe(), 1000, "furnace_source", recipeFactor)
                        end
                    elseif dest.type == "rocket-silo" then
                        transfer(inv, dest.get_inventory(defines.inventory.rocket_silo_input), dest.get_recipe(), 1000, "rocket_silo_input", recipeFactor)
                    else
                        transfer(inv, dest.get_inventory(defines.inventory.lab_input), nil, 5, "lab_input")
                    end
                    
                    transfer(inv, dest.get_inventory(defines.inventory.fuel), nil, 5, "fuel")
                else
                    ithChest.neighbors[j] = nil
                    break
                end
            end
        else
            state.requesterChests[i] = nil
            break
        end
    end
    
    -- remove remembered removed active/passive chests
    for i, item in pairs(state.replaceProviders) do
        if item.tick + replaceTimeout < tick then
            state.replaceProviders[i] = nil
            break
        end
    end
end
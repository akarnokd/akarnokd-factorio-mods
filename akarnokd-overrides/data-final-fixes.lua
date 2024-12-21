function contains(tbl, item)
   for _, e in pairs(tbl) do
       if e == item then
          return true
       end
   end
   return false
end

local stackSize = settings.startup["akarnokd-override-stack-size"].value
local stackSizeEnable = settings.startup["akarnokd-override-stack-size-enable"].value
local machineSpeed = settings.startup["akarnokd-override-machine-speed"].value
local machineSpeedEnable = settings.startup["akarnokd-override-machine-speed-enable"].value
local poleReach = settings.startup["akarnokd-override-pole-reach"].value
local characterReach = settings.startup["akarnokd-override-character-reach"].value
local characterSpeed = settings.startup["akarnokd-override-character-speed"].value
local droneSpeed = settings.startup["akarnokd-override-drone-speed"].value
local droneCapacity = settings.startup["akarnokd-override-drone-capacity"].value
local characterMiningSpeed = settings.startup["akarnokd-override-character-mining-speed"].value
local minerRange = settings.startup["akarnokd-override-miner-range"].value
local earlyRobots = settings.startup["akarnokd-override-early-robots"].value
local cheese = settings.startup["akarnokd-override-cheese"].value
local recp = settings.startup["akarnokd-override-recipe-mult"].value
local recpin = settings.startup["akarnokd-override-recipe-in-mult"].value
local roboLogRad = settings.startup["akarnokd-override-roboport-supply-range"].value
local roboConstRad = settings.startup["akarnokd-override-roboport-build-range"].value

for _, pertype in pairs(data.raw) do
  for _, item in pairs(pertype) do

    if stackSizeEnable then
        if item.stack_size and (not item.flags or not contains(item.flags, "not-stackable"))
            and item.name ~= "upgrade-planner" 
            and item.name ~= "blueprint-book"
            and item.name ~= "spidertron-remote"
            and item.name ~= "nullius-mecha-remote"
            and item.name ~= "deconstruction-planner"
            and item.name ~= "item-with-inventory"
            and not item.inventory_size_bonus
            and not item.equipment_grid
        then
            item.stack_size = stackSize
        end
    end
    
    if machineSpeedEnable then
        if item.crafting_speed then
            item.crafting_speed = machineSpeed
        end
        
        if item.mining_speed then
            item.mining_speed = machineSpeed
        end

        if item.pumping_speed then
            item.pumping_speed = machineSpeed
        end
    end

    if item.speed and item.max_energy and item.energy_per_tick and item.energy_per_move and item.max_payload_size then
       item.speed = droneSpeed
       item.max_energy = "1.5MJ"
       item.energy_per_tick = "0.001kJ"
       item.energy_per_move = "0.01kJ"
       item.max_payload_size = droneCapacity
    end
    
    if item.maximum_wire_distance and item.supply_area_distance then
        item.maximum_wire_distance = poleReach
        item.supply_area_distance = poleReach
    end
    
    if item.mining_speed and item.resource_searching_radius then
        item.resource_searching_radius = item.resource_searching_radius + minerRange
    end
    
    if item.name == "roboport" and item.logistics_radius then
        item.logistics_radius = roboLogRad
    end

    if item.name == "roboport" and item.construction_radius then
        item.construction_radius = roboConstRad
    end
    
  end
end

local theCharacter = data.raw["character"]["character"]
theCharacter.build_distance = characterReach
theCharacter.drop_item_distance = characterReach
theCharacter.reach_distance = characterReach
theCharacter.item_pickup_distance = 10
theCharacter.loot_pickup_distance = 20
theCharacter.reach_resource_distance = characterReach
theCharacter.running_speed = characterSpeed
theCharacter.distance_per_frame = characterSpeed - 0.02
theCharacter.mining_speed = characterMiningSpeed

local function updateRecipe(recipe, mult)
    recipe.enabled = true
    recipe.ingredients =
    {
      {type = "item", name = "iron-plate", amount = 6 * mult},
      {type = "item", name = "electronic-circuit", amount = 3 * mult},
      {type = "item", name = "copper-cable", amount = 5 * mult}
    }
end


if earlyRobots then

    updateRecipe(data.raw["recipe"]["roboport"], 2)
    updateRecipe(data.raw["recipe"]["logistic-robot"], 1)
    updateRecipe(data.raw["recipe"]["construction-robot"], 1)

end

local function updateRecipe2(recipe)
    recipe.enabled = true
    recipe.ingredients =
    {
      {type = "item", name = "iron-ore", amount = 1},
    }
end

if cheese then

    updateRecipe2(data.raw["recipe"]["artillery-turret"])
    updateRecipe2(data.raw["recipe"]["artillery-shell"])

end

if recp > 1 or recpin > 1 then

    for _, a in pairs(data.raw.recipe) do
        -- log(a.name)
        if recpin > 1 and a.ingredients then
            for _, ingr in pairs(a.ingredients) do
                ingr.amount = ingr.amount * recpin
            end
        end
        if recp > 1 and a.results then
            -- log("  " .. a.name .. " results")
            for _, res in pairs(a.results) do
                local itm = data.raw[res.type][res.name]
                if not itm then
                    itm = data.raw["tool"][res.name]
                end
                if not itm then
                    itm = data.raw["ammo"][res.name]
                end
                if not itm then
                    itm = data.raw["rail-planner"][res.name]
                end
                if not itm then
                    itm = data.raw["module"][res.name]
                end
                -- log(serpent.block(itm))
                -- log("    " .. a.name .. " item " .. tostring(itm ~= nil))
                if itm then
                    -- log("    " .. a.name .. " stack " .. (itm.item_stack or "nil"))
                    if (not itm.stack_size) or (itm.stack_size > 1) then
                        res.amount = res.amount * recp
                        -- log("   " .. a.name .. " now " .. res.amount)
                    end
                end
            end
        end
    end

end
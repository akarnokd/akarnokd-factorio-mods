function contains(tbl, item)
   for _, e in pairs(tbl) do
       if e == item then
          return true
       end
   end
   return false
end

local stackSize = settings.startup["akarnokd-override-stack-size"].value
local machineSpeed = settings.startup["akarnokd-override-machine-speed"].value
local poleReach = settings.startup["akarnokd-override-pole-reach"].value
local characterReach = settings.startup["akarnokd-override-character-reach"].value
local characterSpeed = settings.startup["akarnokd-override-character-speed"].value
local droneSpeed = settings.startup["akarnokd-override-drone-speed"].value
local droneCapacity = settings.startup["akarnokd-override-drone-capacity"].value
local characterMiningSpeed = settings.startup["akarnokd-override-character-mining-speed"].value

for _, pertype in pairs(data.raw) do
  for _, item in pairs(pertype) do

    if item.stack_size and (not item.flags or not contains(item.flags, "not-stackable"))
        and item.name ~= "upgrade-planner" and item.name ~= "blueprint-book"
        and item.name ~= "deconstruction-planner" and item.name ~= "item-with-inventory"
        and not item.inventory_size_bonus
    then
        item.stack_size = stackSize
    end
    
    if item.crafting_speed then
        item.crafting_speed = machineSpeed
    end
    
    if item.mining_speed then
        item.mining_speed = machineSpeed
    end

    if item.pumping_speed then
        item.pumping_speed = machineSpeed
    end

    if item.speed and item.max_energy and item.energy_per_tick and item.energy_per_move and item.max_payload_size then
       item.speed = 0.5
       item.max_energy = "1.5MJ"
       item.energy_per_tick = "0.001kJ"
       item.energy_per_move = "0.01kJ"
       item.max_payload_size = 50
    end
    
    if item.maximum_wire_distance and item.supply_area_distance then
        item.maximum_wire_distance = poleReach
        item.supply_area_distance = poleReach
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

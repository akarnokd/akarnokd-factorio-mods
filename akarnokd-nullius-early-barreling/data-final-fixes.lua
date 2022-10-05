if data.raw["technology"]["nullius-barreling-1"] then

local barreling1 = data.raw["technology"]["nullius-barreling-1"]
barreling1.unit.ingredients = { { "nullius-geology-pack", 1 } }
barreling1.prerequisites = nil

local barreling2 = data.raw["technology"]["nullius-barreling-2"]
barreling2.unit.ingredients = { { "nullius-geology-pack", 1 } }
barreling2.prerequisites = { "nullius-barreling-1" }

local emptyBarrel = data.raw["recipe"]["nullius-barrel"]
emptyBarrel.ingredients = { { type="item", name="nullius-iron-sheet", amount=3 } }

end

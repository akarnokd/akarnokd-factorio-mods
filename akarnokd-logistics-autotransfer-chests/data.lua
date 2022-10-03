local function makeIcon(item, r, g, b, a)
    item.icons = {
        {
            icon = item.icon,
            tint = { r = r, g = g, b = b, a = a }
        }
    }
end

local function updateRecipe(recipe, item)
    recipe.name = item.name
    recipe.result = item.name
    recipe.enabled = true
    recipe.ingredients =
    {
      {"iron-plate", 6},
      {"electronic-circuit", 3},
      {"copper-cable", 5}
    }
end

local function copyAndRename(theType, name, newName)
    local copy = table.deepcopy(data.raw[theType][name])
    copy.name = newName
    copy.minable = { mining_time = 0.1, result = newName }
    return copy
end

local passiveProvider = table.deepcopy(data.raw["item"]["logistic-chest-passive-provider"])
local activeProvider = table.deepcopy(data.raw["item"]["logistic-chest-active-provider"])
local requester = table.deepcopy(data.raw["item"]["logistic-chest-requester"])

passiveProvider.name = "akarnokd-latc-passive"
passiveProvider.place_result = "akarnokd-latc-passive"
passiveProvider.order = "b[storage]-d[akarnokd-latc-passive]"

activeProvider.name = "akarnokd-latc-active"
activeProvider.place_result = "akarnokd-latc-active"
activeProvider.order = "b[storage]-d[akarnokd-latc-active]"

requester.name = "akarnokd-latc-requester"
requester.place_result = "akarnokd-latc-requester"
requester.order = "b[storage]-d[akarnokd-latc-requester]"

makeIcon(passiveProvider, 0, 1, 0, 0.3)
makeIcon(activeProvider, 1, 1, 0, 0.3)
makeIcon(requester, 0, 0, 1, 0.3)

local passiveEntity = copyAndRename("logistic-container", "logistic-chest-passive-provider", passiveProvider.name)
local activeEntity = copyAndRename("logistic-container", "logistic-chest-active-provider", activeProvider.name)
local requesterEntity = copyAndRename("logistic-container", "logistic-chest-requester", requester.name)

local passiveProviderRecipe = table.deepcopy(data.raw["recipe"]["logistic-chest-passive-provider"]);
local activeProviderRecipe = table.deepcopy(data.raw["recipe"]["logistic-chest-active-provider"]);
local requesterRecipe = table.deepcopy(data.raw["recipe"]["logistic-chest-requester"]);

updateRecipe(passiveProviderRecipe, passiveProvider)
updateRecipe(activeProviderRecipe, activeProvider)
updateRecipe(requesterRecipe, requester)

data:extend{ passiveProvider, passiveProviderRecipe, passiveEntity }
data:extend{ activeProvider, activeProviderRecipe, activeEntity }
data:extend{ requester, requesterRecipe, requesterEntity }
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
    recipe.results = {{type="item", name=item.name, amount=1}} 
    recipe.enabled = true
    recipe.ingredients =
    {
      {type = "item", name = "iron-plate", amount = 6},
      {type = "item", name = "electronic-circuit", amount = 3},
      {type = "item", name = "copper-cable", amount = 5}
    }
end

local function copyAndRename(theType, name, newName)
    local copy = table.deepcopy(data.raw[theType][name])
    copy.name = newName
    copy.minable = { mining_time = 0.1, result = newName }
    return copy
end

local passiveProvider = table.deepcopy(data.raw["item"]["passive-provider-chest"])
local activeProvider = table.deepcopy(data.raw["item"]["active-provider-chest"])
local requester = table.deepcopy(data.raw["item"]["requester-chest"])

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

local passiveEntity = copyAndRename("logistic-container", "passive-provider-chest", passiveProvider.name)
local activeEntity = copyAndRename("logistic-container", "active-provider-chest", activeProvider.name)
local requesterEntity = copyAndRename("logistic-container", "requester-chest", requester.name)

local passiveProviderRecipe = table.deepcopy(data.raw["recipe"]["passive-provider-chest"]);
local activeProviderRecipe = table.deepcopy(data.raw["recipe"]["active-provider-chest"]);
local requesterRecipe = table.deepcopy(data.raw["recipe"]["requester-chest"]);

updateRecipe(passiveProviderRecipe, passiveProvider)
updateRecipe(activeProviderRecipe, activeProvider)
updateRecipe(requesterRecipe, requester)

data:extend{ passiveProvider, passiveProviderRecipe, passiveEntity }
data:extend{ activeProvider, activeProviderRecipe, activeEntity }
data:extend{ requester, requesterRecipe, requesterEntity }
local steelChest = table.deepcopy(data.raw["container"]["steel-chest"])

local function create_wide_steel_chest(box, width, height, postfix)
    local steelChest = table.deepcopy(data.raw["container"]["steel-chest"])
    steelChest.name = steelChest.name .. "-wide-" .. postfix
    steelChest.circuit_wire_max_distance = 50
    steelChest.inventory_size = steelChest.inventory_size * 6
    steelChest.collision_box = box
    steelChest.selection_box = box

    steelChest.picture = {
        filename = "__trainio__/graphics/steel-chest-" .. postfix .. ".png",
        priority = "extra-high",
        width = width,
        height = height,
        shift = {0, 0},
        scale = 0.5,
    }

    local steelChestRecipe = table.deepcopy(data.raw["recipe"]["steel-chest"])
    steelChestRecipe.name = steelChestRecipe.name .. "-wide-" .. postfix
    steelChestRecipe.result = steelChestRecipe.result .. "-wide-" .. postfix

    local steelChestItem = table.deepcopy(data.raw["item"]["steel-chest"])
    steelChestItem.name = steelChestItem.name .. "-wide-" .. postfix
    steelChestItem.place_result = steelChestItem.place_result .. "-wide-" .. postfix
    steelChestItem.icon = "__trainio__/graphics/steel-chest-" .. postfix .. "-icon.png"

    return steelChest, steelChestRecipe, steelChestItem
end

local box = {{-3, -0.5}, {3, 0.5}}
local steelChestH, steelChestRecipeH, steelChestItemH = create_wide_steel_chest(box, 64 * 6, 80, "h")


local box = {{-0.5, -3}, {0.5, 3}}
local steelChestV, steelChestRecipeV, steelChestItemV = create_wide_steel_chest(box, 64, 80 * 6, "v")

data:extend{
    steelChestH, steelChestRecipeH, steelChestItemH,
    steelChestV, steelChestRecipeV, steelChestItemV,
}

table.insert(
    data.raw["technology"]["steel-processing"].effects,
    {type = "unlock-recipe", recipe = steelChestRecipeH.name}
)

table.insert(
    data.raw["technology"]["steel-processing"].effects,
    {type = "unlock-recipe", recipe = steelChestRecipeV.name}
)

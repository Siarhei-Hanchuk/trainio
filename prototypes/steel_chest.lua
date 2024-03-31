local steelChest = table.deepcopy(data.raw["container"]["steel-chest"])

steelChest.name = steelChest.name .. "-wide"
steelChest.circuit_wire_max_distance = 50
steelChest.inventory_size = steelChest.inventory_size * 6
steelChest.collision_box = {{-3, -0.5}, {3, 0.5}}
steelChest.selection_box = {{-3, -0.5}, {3, 0.5}}

steelChest.picture = {
    filename = "__trainio__/graphics/hr-steel-chest.png",
    priority = "extra-high",
    width = 64 * 6,
    height = 80,
    shift = {0, 0},
    scale = 0.5,
}

local steelChestRecipe = table.deepcopy(data.raw["recipe"]["steel-chest"])
steelChestRecipe.name = steelChestRecipe.name .. "-wide"
steelChestRecipe.result = steelChestRecipe.result .. "-wide"

local steelChestItem = table.deepcopy(data.raw["item"]["steel-chest"])
steelChestItem.name = steelChestItem.name .. "-wide"
steelChestItem.place_result = steelChestItem.place_result .. "-wide"

data:extend{
    steelChest, steelChestItem, steelChestRecipe,
}

table.insert(
    data.raw["technology"]["steel-processing"].effects,
    {type = "unlock-recipe", recipe = steelChestRecipe.name}
)

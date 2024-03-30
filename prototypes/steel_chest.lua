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

data:extend{
    steelChest,
}
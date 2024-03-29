local steelChest = table.deepcopy(data.raw["container"]["steel-chest"])

steelChest.circuit_wire_max_distance = 25

data:extend{
    steelChest,
}
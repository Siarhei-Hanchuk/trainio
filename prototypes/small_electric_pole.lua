local function create_small_electric_pole(type)
    local smallElectricPole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
    smallElectricPole.maximum_wire_distance = 25
    smallElectricPole.name = "small-electric-pole-" .. type

    local item = table.deepcopy(data.raw["item"]["small-electric-pole"])
    item.name = item.name .. "-" .. type
    item.place_result = item.place_result .. "-" .. type

    return smallElectricPole, item
end

entityIn, itemIn = create_small_electric_pole("in")
entityOut, itemOut = create_small_electric_pole("out")

data:extend{
    entityIn, itemIn,
    entityOut, itemOut,
}
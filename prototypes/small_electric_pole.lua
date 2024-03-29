local function create_small_electric_pole(type)
    local smallElectricPole = table.deepcopy(data.raw["electric-pole"]["small-electric-pole"])
    smallElectricPole.maximum_wire_distance = 25
    smallElectricPole.name = "station-" .. type

    smallElectricPole.supply_area_distance = 0

    local item = table.deepcopy(data.raw["item"]["small-electric-pole"])
    item.name = "station-" .. type
    item.place_result = "station-" .. type

    return smallElectricPole, item
end

entityIn, itemIn = create_small_electric_pole("loader")
entityOut, itemOut = create_small_electric_pole("unloader")

data:extend{
    entityIn, itemIn,
    entityOut, itemOut,
}
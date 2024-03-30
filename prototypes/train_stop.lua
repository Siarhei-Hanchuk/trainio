local function create_train_station(type)
    local entity = table.deepcopy(data.raw["train-stop"]["train-stop"])
    entity.circuit_wire_max_distance = 50
    entity.name = entity.name .. "-" .. type

    local item = table.deepcopy(data.raw["item"]["train-stop"])
    item.name = item.name .. "-" .. type
    item.place_result = item.place_result .. "-" .. type

    return entity, item
end

entityIn, itemIn = create_train_station("loader")
entityOut, itemOut = create_train_station("unloader")

data:extend{
    entityIn, itemIn,
    entityOut, itemOut,
}
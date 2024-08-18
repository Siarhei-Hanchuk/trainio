local function create_train_station(type)
    local entity = table.deepcopy(data.raw["train-stop"]["train-stop"])
    entity.circuit_wire_max_distance = 50
    entity.name = entity.name .. "-" .. type

    local item = table.deepcopy(data.raw["item"]["train-stop"])
    item.name = item.name .. "-" .. type
    item.place_result = item.place_result .. "-" .. type

    local recipe = table.deepcopy(data.raw["recipe"]["train-stop"])
    recipe.name = recipe.name .. "-" .. type
    recipe.result = "train-stop-" .. type

    table.insert(
        data.raw["technology"]["automated-rail-transportation"].effects,
        {type = "unlock-recipe", recipe = recipe.name}
    )

    entity.radius_visualisation_specification = {
        sprite = {
            filename="__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
            width=10,
            height=10,
        },
        distance = 50,
        draw_in_cursor = true,
        draw_on_selection = true,
    }

    return entity, item, recipe
end

entityIn, itemIn, recipeIn = create_train_station("loader")
entityOut, itemOut, recipeOut = create_train_station("unloader")

data:extend{
    entityIn, itemIn, recipeIn,
    entityOut, itemOut, recipeOut,
}

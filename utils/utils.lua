function enable_recipes()
    local recipe_names = {"steel-chest-wide", "train-stop-loader", "train-stop-unloader"}

    for _, recipe_name in ipairs(recipe_names) do
        local recipe = game.players[1].force.recipes[recipe_name]
        recipe.enabled = true
    end
end

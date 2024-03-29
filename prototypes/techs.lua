techs = {
    'automation', 'logistics', 'steel-processing', 'automation', 'railway', 'automated-rail-transportation',
    'optics', 'electric-energy-distribution-1', 'miniloader', 'engine', 'rail-signals',
    -- 'ultra-fast-configurable-inserter'
}

local ingredients = { { "automation-science-pack", 1, }, }

for _, tech in ipairs(techs) do
    local tech = table.deepcopy(data.raw["technology"][tech])
    tech.prerequisites = {}
    tech.unit.count = 1
    tech.unit.ingredients = ingredients
    tech.enabled = true
    data:extend{tech}
end

-- script.on_event(defines.events.on_player_created, function(event)
--     local player = game.players[event.player_index]

--     local techs = {
--         'automation', 'logistics', 'steel-processing', 'automation', 'railway', 'automated-rail-transportation',
--         'optics', 'electric-energy-distribution-1', 'miniloader', 'engine', 'rail-signals',
--         -- 'ultra-fast-configurable-inserter'
--     }

--     for _, tech in ipairs(techs) do
--         player.force.technologies[tech].researched = true
--     end
-- end)


local entities_to_enable = {
    'long-handed-inserter', 'fast-inserter', 'filter-inserter', 'stack-inserter', 'stack-filter-inserter',
    'express-transport-belt', 'express-underground-belt', 'express-splitter',
    'engine-unit', 'electric-engine-unit', 'electric-furnace', 'steel-furnace', 'stone-furnace',
    'locomotive', 'cargo-wagon', 'fluid-wagon', 'artillery-wagon',
    'electric-pole', 'medium-electric-pole', 'big-electric-pole', 'substation',
}

for _, item in pairs(data.raw.technology) do
    if item.effects then
        for i, effect in ipairs(item.effects) do
            if effect.type == "unlock-recipe" and entities_to_enable[effect.recipe] then
                table.remove(item.effects, i)
            end
        end
    end
end

for _, item in ipairs(entities_to_enable) do
    if data.raw.recipe[item] then
        data.raw.recipe[item].enabled = true
    end
end

-- for _, entity in ipairs(entities_to_enable) do
--     if data.raw["electric-pole"][entity] then
--         data.raw["electric-pole"][entity].enabled = true
--     elseif data.raw["transport-belt"][entity] then
--         data.raw["transport-belt"][entity].enabled = true
--     elseif data.raw["inserter"][entity] then
--         data.raw["inserter"][entity].enabled = true
--     elseif data.raw["item"][entity] then
--         data.raw["item"][entity].enabled = true
--     elseif data.raw["fluid-wagon"][entity] then
--         data.raw["fluid-wagon"][entity].enabled = true
--     elseif data.raw["locomotive"][entity] then
--         data.raw["locomotive"][entity].enabled = true
--     end
-- end


local entities_to_disable = {
    'small-electric-pole',
}

for _, item in ipairs(entities_to_disable) do
    if data.raw.recipe[item] then
        data.raw.recipe[item].enabled = false
    end
end

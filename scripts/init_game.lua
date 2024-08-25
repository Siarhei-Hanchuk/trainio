local function unlock_techs(event)
    local player = game.get_player(event.player_index)

    if player then
        local techs = {
            'steel-processing', 'automation', 'railway', 'automated-rail-transportation',
            'electric-energy-distribution-1', 'engine', 'rail-signals', 'circuit-network'
        }

        for _, tech in ipairs(techs) do
            player.force.technologies[tech].researched = true
        end
    end
end

script.on_event(defines.events.on_player_created, function(event)
    unlock_techs(event)
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
    local entity = event.entity
    if entity.type == "mining-drill" then
        entity.direction = event.previous_direction
    end
end)

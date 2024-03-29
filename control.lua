local tick_interval = 60

local function transfer_items_from_containers_to_wagons(containers, wagons)
    for _, container in pairs(containers) do
        local items = container.get_inventory(defines.inventory.chest).get_contents()

        for item, count in pairs(items) do
            local total_inserted = 0

            for _, wagon in pairs(wagons) do
                if wagon.type == "cargo-wagon" then
                    local inserted = wagon.get_inventory(defines.inventory.cargo_wagon).insert({name = item, count = count - total_inserted})

                    total_inserted = total_inserted + inserted

                    if total_inserted == count then
                        break
                    end
                end
            end

            if total_inserted > 0 then
                container.get_inventory(defines.inventory.chest).remove({name = item, count = total_inserted})
            end
        end
    end
end

local function transfer_items_from_wagons_to_containers(containers, wagons)
    for _, wagon in pairs(wagons) do
        local items = wagon.get_inventory(defines.inventory.cargo_wagon).get_contents()

        for item, count in pairs(items) do
            local total_inserted = 0

            for _, container in pairs(containers) do
                if container.type == "container" then
                    local inserted = container.get_inventory(defines.inventory.chest).insert({name = item, count = count - total_inserted})

                    total_inserted = total_inserted + inserted

                    if total_inserted == count then
                        break
                    end
                end
            end

            if total_inserted > 0 then
                wagon.get_inventory(defines.inventory.cargo_wagon).remove({name = item, count = total_inserted})
            end
        end
    end
end

local function get_wagons_and_containers(load_station)
    local train_stops = {}
    local containers = {}
    local wagons = {}

    local connected_entities = load_station.neighbours["green"]

    for _, connected_entity in pairs(connected_entities) do
        if connected_entity.type == "train-stop" then
            table.insert(train_stops, connected_entity)
        elseif connected_entity.type == "container" then
            table.insert(containers, connected_entity)
        end
    end

    for _, train_stop in pairs(train_stops) do
        local train = train_stop.get_stopped_train()
        if train then
            for _, wagon in pairs(train.cargo_wagons) do
                table.insert(wagons, wagon)
            end
        end
    end

    return wagons, containers
end

local function on_nth_tick(event)
    local surfaces = game.surfaces

    -- local player = game.players[event.player_index]
    -- player.force.technologies['steel-processing'].researched = true

    for _, surface in pairs(surfaces) do
        local loaders = surface.find_entities_filtered{name = "station-loader"}

        for _, loader in pairs(loaders) do
            local wagons, containers = get_wagons_and_containers(loader)
            transfer_items_from_containers_to_wagons(containers, wagons)
        end

        local unlodaders = surface.find_entities_filtered{name = "station-unloader"}

        for _, unloader in pairs(unlodaders) do
            local wagons, containers = get_wagons_and_containers(unloader)
            transfer_items_from_wagons_to_containers(containers, wagons)
        end
    end
end

script.on_nth_tick(tick_interval, on_nth_tick)

-- script.on_event(defines.events.on_player_created, function(event)
--     local player = game.players[event.player_index]

--     local items_to_give = {
--         ['iron-plate'] = 100,
--         ['copper-plate'] = 100,
--         ['steel-plate'] = 50,
--         ['locomotive'] = 2,
--         ['cargo-wagon'] = 4,
--         ['boiler'] = 1,
--         ['steam-engine'] = 2,
--     }

--     for item, count in pairs(items_to_give) do
--         player.insert{name=item, count=count}
--     end
-- end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.players[event.player_index]
    players.force.technologies['steel-processing'].researched = true
end)
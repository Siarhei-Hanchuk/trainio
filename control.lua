local radius = 10
local tick_interval = 60

local function transfer_items_from_container_to_wagons(containers, wagons)
    for _, container in pairs(containers) do
        if container.type == "container" then
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
end

local function on_nth_tick(event)
    local surfaces = game.surfaces

    for _, surface in pairs(surfaces) do
        local small_electric_poles = surface.find_entities_filtered{name = "small-electric-pole"}

        for _, small_electric_pole in pairs(small_electric_poles) do
            local center_position = small_electric_pole.position

            local train_stops = {}

            local connected_entities = small_electric_pole.neighbours["green"]

            for _, connected_entity in pairs(connected_entities) do
                if connected_entity.type == "train-stop" then
                    table.insert(train_stops, connected_entity)
                end
            end

            local containers = surface.find_entities_filtered{
                area = {{center_position.x - radius, center_position.y - radius}, {center_position.x + radius, center_position.y + radius}},
                type = "container"
            }

            local wagons = {}
            for _, train_stop in pairs(train_stops) do
                local train = train_stop.get_stopped_train()
                if train then
                    for _, wagon in pairs(train.cargo_wagons) do
                        table.insert(wagons, wagon)
                    end
                end
            end

            transfer_items_from_container_to_wagons(containers, wagons)
        end
    end
end

script.on_nth_tick(tick_interval, on_nth_tick)
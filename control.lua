local tick_interval = 60

local function transfer_items_from_containers_to_wagons(containers, wagons)
    local device_count = #wagons
    for _, container in pairs(containers) do
        local items = container.get_inventory(defines.inventory.chest).get_contents()

        for item, count in pairs(items) do
            if count == 0 then
                break
            end

            local total_inserted = 0
            local count_per_device = math.floor(count / device_count)
            local remainder = count % device_count

            for i, wagon in pairs(wagons) do
                local to_insert = count_per_device + ((i == 1) and remainder or 0)

                if to_insert == 0 then
                    break
                end

                local inserted = wagon.get_inventory(defines.inventory.cargo_wagon).insert({name = item, count = to_insert})
                total_inserted = total_inserted + inserted

                if total_inserted == count then
                    break
                end
            end

            if total_inserted > 0 then
                container.get_inventory(defines.inventory.chest).remove({name = item, count = total_inserted})
            end
        end
    end
end

local function transfer_items_from_wagons_to_containers(containers, wagons)
    local device_count = #containers
    for _, wagon in pairs(wagons) do
        local items = wagon.get_inventory(defines.inventory.cargo_wagon).get_contents()

        for item, count in pairs(items) do
            if count == 0 then
                break
            end

            local total_inserted = 0
            local count_per_device = math.floor(count / device_count)
            local remainder = count % device_count

            for i, container in ipairs(containers) do
                local to_insert = count_per_device + ((i == 1) and remainder or 0)

                if to_insert == 0 then
                    break
                end
                local inserted = container.get_inventory(defines.inventory.chest).insert({name = item, count = to_insert})
                total_inserted = total_inserted + inserted

                if total_inserted == count then
                    break
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

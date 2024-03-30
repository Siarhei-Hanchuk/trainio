local tick_interval = 60

local function transfer_items_from_containers_to_wagons(containers, wagons)
    local device_count = #wagons

    if device_count == 0 then
        return
    end

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
                local to_insert = count_per_device + remainder

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

    if device_count == 0 then
        return
    end

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
                local to_insert = count_per_device + remainder

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

local function get_wagons_and_containers(loader)
    local train_stops = {}
    local containers = {}
    local wagons = {}

    local connected_entities = loader.circuit_connected_entities["green"]

    for _, connected_entity in pairs(connected_entities) do
        if connected_entity.type == "train-stop" then
            table.insert(train_stops, connected_entity)
        elseif connected_entity.type == "container" then
            table.insert(containers, connected_entity)
        end
    end

    local train = loader.get_stopped_train()
    if train then
        for _, wagon in pairs(train.cargo_wagons) do
            table.insert(wagons, wagon)
        end
    end

    return wagons, containers
end

local function on_nth_tick(event)
    local surfaces = game.surfaces

    for _, surface in pairs(surfaces) do
        local loaders = surface.find_entities_filtered{name = "train-stop-loader"}

        for _, loader in pairs(loaders) do
            local wagons, containers = get_wagons_and_containers(loader)
            transfer_items_from_containers_to_wagons(containers, wagons)
        end

        local unlodaders = surface.find_entities_filtered{name = "train-stop-unloader"}

        for _, unloader in pairs(unlodaders) do
            local wagons, containers = get_wagons_and_containers(unloader)
            transfer_items_from_wagons_to_containers(containers, wagons)
        end
    end
end

script.on_nth_tick(tick_interval, on_nth_tick)


script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)

    local techs = {
        'steel-processing', 'automation', 'railway', 'automated-rail-transportation',
        'electric-energy-distribution-1', 'engine', 'rail-signals',
    }

    for _, tech in ipairs(techs) do
        player.force.technologies[tech].researched = true
    end
end)


local function init_inventory(event)
    local player = game.get_player(event.player_index)

    if player.character and player.get_main_inventory() then
        player.get_main_inventory().clear()
    end

    player.insert{name="burner-mining-drill-big", count=1}
    player.insert{name="stone-furnace-big", count=1}
    player.insert{name="wood", count=1}
end

script.on_event(defines.events.on_player_created, function(event)
    init_inventory(event)
end)

script.on_event(defines.events.on_cutscene_cancelled, function(event)
    if remote.interfaces["freeplay"] then
        init_inventory(event)
    end
end)

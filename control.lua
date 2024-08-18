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

local function unlock_techs(event)
    local player = game.get_player(event.player_index)

    local techs = {
        'steel-processing', 'automation', 'railway', 'automated-rail-transportation',
        'electric-energy-distribution-1', 'engine', 'rail-signals', 'circuit-network'
    }

    for _, tech in ipairs(techs) do
        player.force.technologies[tech].researched = true
    end
end

script.on_event(defines.events.on_player_created, function(event)
    -- init_inventory(event)
    unlock_techs(event)
end)

script.on_event(defines.events.on_cutscene_cancelled, function(event)
    if remote.interfaces["freeplay"] then
        -- init_inventory(event)
    end
end)


script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    local player = game.get_player(event.player_index)

    if entity.name == "train-stop-loader" then
        local surface = entity.surface
        local position = entity.position

        local chest_position = {x = position.x + 1, y = position.y}

        if surface.can_place_entity{name = "steel-chest", position = chest_position} then
            local chest = surface.create_entity{
                name = "steel-chest",
                position = chest_position,
                force = entity.force,
                create_build_effect_smoke = false
            }

            chest.destructible = false
            chest.minable = false
            chest.operable = false

            if not global.train_stop_chests then
                global.train_stop_chests = {}
            end
            global.train_stop_chests[entity.unit_number] = chest
        else
            player.print("error")
        end
    end
end)

local function remove_linked_chest(entity)
    if global.train_stop_chests and global.train_stop_chests[entity.unit_number] then
        local chest = global.train_stop_chests[entity.unit_number]
        if chest and chest.valid then
            chest.destroy()
        end
        global.train_stop_chests[entity.unit_number] = nil
    end
end

script.on_event(defines.events.on_entity_died, function(event)
    if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    end
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
    if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    end
end)

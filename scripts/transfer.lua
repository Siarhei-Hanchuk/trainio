local function transfer_items_from_to(source_inventories, destination_inventories)
    if #destination_inventories == 0 or #source_inventories == 0 then
        return
    end

    for _, source_inventory in ipairs(source_inventories) do
        local items = source_inventory.get_contents()

        for item, count in pairs(items) do
            for _, destination_inventory in ipairs(destination_inventories) do
                if count == 0 then
                    break
                end

                local inserted = destination_inventory.insert({name = item, count = count})
                if inserted > 0 then
                    source_inventory.remove({name = item, count = inserted})
                    count = count - inserted
                end
            end
        end
    end
end


local function get_inventories(factory, type)
    if factory.name == "assembling-machine-1" or factory.name == "assembling-machine-2" then
        if type == "from-train" then
            return {factory.get_inventory(defines.inventory.assembling_machine_input)}
        elseif type == "to-train" then
            return {factory.get_inventory(defines.inventory.assembling_machine_output)}
        else
            error("not supported")
        end
    elseif factory.name == "boiler" then
        return {factory.get_inventory(defines.inventory.fuel)}
    elseif factory.name == "cargo-wagon" then
        return {factory.get_inventory(defines.inventory.cargo_wagon)}
    elseif factory.name == "stone-furnace" or factory.name == "steel-furnace" or factory.name == "electric-furnace" then
        if type == "from-train" then
            return {factory.get_inventory(defines.inventory.furnace_source), factory.get_inventory(defines.inventory.fuel)}
        elseif type == "to-train" then
            return {factory.get_inventory(defines.inventory.furnace_result)}
        else
            error("not supported")
        end
    else
        error("not supported")
    end
end

local function find_factories_around_train_stop(train_stop, station_type)
    local surface = train_stop.surface
    local position = train_stop.position
    local radius = TRAIN_STOP_RADIUS

    local left_top = {x = position.x - radius, y = position.y - radius}
    local right_bottom = {x = position.x + radius, y = position.y + radius}

    local result_inventories = {}

    local factories = surface.find_entities_filtered{
        area = {left_top, right_bottom},
        name = {
            "assembling-machine-1", "assembling-machine-2", "assembling-machine-3",
            "boiler",
            "stone-furnace", "steel-furnace", "electric-furnace",
        }
    }

    if station_type == "to-train" then
        local miners = surface.find_entities_filtered{
            area = {left_top, right_bottom},
            name = {"burner-mining-drill", "electric-mining-drill"}
        }

        for _, miner in pairs(miners) do
            if global.linked_chests[miner.unit_number] then
                local chest_inventory = global.linked_chests[miner.unit_number].get_inventory(defines.inventory.chest)
                table.insert(result_inventories, chest_inventory)
            end
        end
    end

    for _, factory in pairs(factories) do
        local factory_inventories = get_inventories(factory, station_type)
        for _, factory_inventory in pairs(factory_inventories) do
            table.insert(result_inventories, factory_inventory)
        end
    end

    return result_inventories
end


local function transfer_items_from_station_to_train(station)
    local stationStorage = global.linked_chests[station.unit_number]
    local inventories = {}

    local train = station.get_stopped_train()
    if train then
        for _, wagon in pairs(train.cargo_wagons) do
            local wagon_inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
            table.insert(inventories, wagon_inventory)
        end

        transfer_items_from_to({stationStorage.get_inventory(defines.inventory.chest)}, inventories)
    end
end


local function transfer_items_from_train_to_station(station)
    local stationStorage = global.linked_chests[station.unit_number]
    local inventories = {}

    local train = station.get_stopped_train()
    if train then
        for _, wagon in pairs(train.cargo_wagons) do
            local wagon_inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
            table.insert(inventories, wagon_inventory)
        end

        transfer_items_from_to(inventories, {stationStorage.get_inventory(defines.inventory.chest)})
    end
end


local function transfer_items_from_factories_to_station(station)
    local stationStorage = global.linked_chests[station.unit_number]

    -- TODO: use cache
    factories_inventories = find_factories_around_train_stop(station, "to-train")
    transfer_items_from_to(factories_inventories, {stationStorage.get_inventory(defines.inventory.chest)})
end


local function transfer_items_from_station_factories(station)
    local stationStorage = global.linked_chests[station.unit_number]

    -- TODO: use cache
    factories_inventories = find_factories_around_train_stop(station, "from-train")
    transfer_items_from_to({stationStorage.get_inventory(defines.inventory.chest)}, factories_inventories)
end


script.on_nth_tick(60, function(event)
    local surfaces = game.surfaces

    for _, surface in pairs(surfaces) do
        local loaders = surface.find_entities_filtered{name = "train-stop-to-train"}

        for _, loader in pairs(loaders) do
            transfer_items_from_factories_to_station(loader)
            transfer_items_from_station_to_train(loader)
        end

        local unlodaders = surface.find_entities_filtered{name = "train-stop-from-train"}

        for _, unloader in pairs(unlodaders) do
            transfer_items_from_train_to_station(unloader)
            transfer_items_from_station_factories(unloader)
        end
    end
end)

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


script.on_nth_tick(60, function(event)
    local surfaces = game.surfaces

    for _, surface in pairs(surfaces) do
        local loaders = surface.find_entities_filtered{name = "train-stop-loader"}

        for _, loader in pairs(loaders) do
            local wagons, containers = get_wagons_and_containers_inventories(loader)
            transfer_items_from_to(containers, wagons)

            -- factories = find_factories_around_train_stop(loader)
            -- transfer_items_from_to(factories, containers, "loading")
        end

        -- local unlodaders = surface.find_entities_filtered{name = "train-stop-unloader"}

        -- for _, unloader in pairs(unlodaders) do
        --     local wagons, containers = get_wagons_and_containers(unloader)
        --     transfer_items_from_to(wagons, containers)

        --     factories = find_factories_around_train_stop(unloader)
        --     transfer_items_from_to(containers, factories, "unloading")
        -- end
    end
end)

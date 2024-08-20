local tick_interval = 1

local function get_inventory(factory, type)
    if factory.name == "assembling-machine-1" or factory.name == "assembling-machine-2" then
        if type == "unloading" then
            return factory.get_inventory(defines.inventory.assembling_machine_input)
        elseif type == "loading" then
            return factory.get_inventory(defines.inventory.assembling_machine_output)
        else
            error("not supported")
        end
    elseif factory.name == "boiler" then
        return factory.get_inventory(defines.inventory.fuel)
    elseif factory.name == "steel-chest" then
        return factory.get_inventory(defines.inventory.chest)
    elseif factory.name == "cargo-wagon" then
        return factory.get_inventory(defines.inventory.cargo_wagon)
    else
        error("not supported")
    end
end

local function transfer_items_from_to(sources, destinations, type)
    local device_count = #destinations

    if device_count == 0 then
        return
    end

    for _, source in pairs(sources) do
        local items = get_inventory(source, type).get_contents()

        for item, count in pairs(items) do
            if count == 0 then
                break
            end

            local total_inserted = 0
            local count_per_device = math.floor(count / device_count)
            local remainder = count % device_count

            for _, destination in ipairs(destinations) do
                local to_insert = count_per_device + remainder

                if to_insert == 0 then
                    break
                end

                local inserted = get_inventory(destination, type).insert({name = item, count = to_insert})
                total_inserted = total_inserted + inserted

                if total_inserted == count then
                    break
                end
            end

            if total_inserted > 0 then
                get_inventory(source, type).remove({name = item, count = total_inserted})
            end
        end
    end
end

local function find_factories_around_train_stop(train_stop)
    local surface = train_stop.surface
    local position = train_stop.position
    local radius = 10

    local left_top = {x = position.x - radius, y = position.y - radius}
    local right_bottom = {x = position.x + radius, y = position.y + radius}

    local factories = surface.find_entities_filtered{
        area = {left_top, right_bottom},
        name = {"assembling-machine-1", "assembling-machine-2", "boiler"}
    }

    local all_chests = surface.find_entities_filtered{
        area = {left_top, right_bottom},
        name = {"steel-chest"}
    }

    mining_chests = {}

    for _, chest in pairs(all_chests) do
        if global.source_chests[chest.unit_number] then
            table.insert(factories, chest)
        end
    end

    return factories
end

local function get_wagons_and_containers(station)
    local containers = {}
    local wagons = {}

    local chest = global.linked_chests[station.unit_number]

    if chest then
        table.insert(containers, chest)
    end

    local train = station.get_stopped_train()
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
            transfer_items_from_to(containers, wagons)

            factories = find_factories_around_train_stop(loader)
            transfer_items_from_to(factories, containers, "loading")
        end

        local unlodaders = surface.find_entities_filtered{name = "train-stop-unloader"}

        for _, unloader in pairs(unlodaders) do
            local wagons, containers = get_wagons_and_containers(unloader)
            transfer_items_from_to(wagons, containers)

            factories = find_factories_around_train_stop(unloader)
            transfer_items_from_to(containers, factories, "unloading")
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

function add_chest_to_station(entity)
    local surface = entity.surface
    local position = entity.position

    local chest_position;

    if entity.direction == 0 then --SN
        chest_position = {x = position.x - 1, y = position.y - 2}
    elseif entity.direction == 2 then --WE
        chest_position = {x = position.x + 1, y = position.y - 1}
    elseif entity.direction == 4 then --NS
        chest_position = {x = position.x + 0, y = position.y + 1}
    elseif entity.direction == 6 then --EW
        chest_position = {x = position.x - 2, y = position.y}
    else
        print("error")
    end

    if surface.can_place_entity{name = "steel-chest", position = chest_position} then
        local chest = surface.create_entity{
            name = "steel-chest",
            position = chest_position,
            force = entity.force,
            create_build_effect_smoke = false
        }

        chest.destructible = false
        chest.minable = false

        if not global.linked_chests then
            global.linked_chests = {}
        end
        global.linked_chests[entity.unit_number] = chest
    else
        print("error")
    end
end

function add_chest_to_drill(entity)
    local surface = entity.surface
    local position = entity.position

    local chest_position;


    if entity.name == "burner-mining-drill" then
        if entity.direction == 0 then --SN
            chest_position = {x = position.x - 1, y = position.y - 2}
        elseif entity.direction == 2 then --WE
            chest_position = {x = position.x + 1, y = position.y - 1}
        elseif entity.direction == 4 then --NS
            chest_position = {x = position.x + 0, y = position.y + 1}
        elseif entity.direction == 6 then --EW
            chest_position = {x = position.x - 2, y = position.y}
        else
            print("error")
            return
        end
    else
        if entity.direction == 0 then --SN
            chest_position = {x = position.x, y = position.y - 2}
        elseif entity.direction == 2 then --WE
            chest_position = {x = position.x + 2, y = position.y}
        elseif entity.direction == 4 then --NS
            chest_position = {x = position.x, y = position.y + 2}
        elseif entity.direction == 6 then --EW
            chest_position = {x = position.x - 2, y = position.y}
        else
            print("error")
            return
        end
    end


    if surface.can_place_entity{name = "steel-chest", position = chest_position} then
        local chest = surface.create_entity{
            name = "steel-chest",
            position = chest_position,
            force = entity.force,
            create_build_effect_smoke = false
        }

        chest.destructible = false
        chest.minable = false

        if not global.linked_chests then
            global.linked_chests = {}
        end
        global.linked_chests[entity.unit_number] = chest
        if not global.source_chests then
            global.source_chests = {}
        end
        global.source_chests[chest.unit_number] = chest
    else
        print("error")
    end
end


script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.created_entity

    if entity.name == "train-stop-loader" or entity.name == "train-stop-unloader" then
        add_chest_to_station(entity)
    end

    if entity.name == "burner-mining-drill" or entity.name == "electric-mining-drill" then
        add_chest_to_drill(entity)
    end

end)

local function remove_linked_chest(entity)
    if global.linked_chests and global.linked_chests[entity.unit_number] then
        local chest = global.linked_chests[entity.unit_number]
        if chest and chest.valid then
            if chest.get_inventory(defines.inventory.chest).is_empty() then
                chest.destroy()
            else
                chest.minable = true
            end
        end
        global.linked_chests[entity.unit_number] = nil
        global.source_chests[chest.unit_number] = nil
    end
end

script.on_event(defines.events.on_entity_died, function(event)
    -- if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    -- end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    -- if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    -- end
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
    -- if event.entity.name == "train-stop-loader" then
        remove_linked_chest(event.entity)
    -- end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    if entity and entity.type == "container" and entity.name == "steel-chest" then
        if not player.gui.left.custom_chest_gui then
            local gui = player.gui.left.add{
                type = "frame",
                name = "custom_chest_gui",
                caption = "Select Item",
                direction = "vertical",
                style = "frame"
            }

            gui.add{
                type = "choose-elem-button",
                name = "choose_item_button",
                elem_type = "item",
                style = "button"
            }

            local chest = player.opened
            if chest and chest.type == "container" and global.chest_item_selection then
                local selected_item = global.chest_item_selection[chest.unit_number]
                if selected_item then
                    gui.choose_item_button.elem_value = selected_item
                end
            end
        end
    end
end)

script.on_event(defines.events.on_gui_elem_changed, function(event)
    if event.element and event.element.name == "choose_item_button" then
        local player = game.players[event.player_index]
        local selected_item = event.element.elem_value

        if selected_item then
            player.print("Item selected1: " .. selected_item)

            local chest = player.opened
            if chest and chest.type == "container" then
                if not global.chest_item_selection then
                    global.chest_item_selection = {}
                end
                global.chest_item_selection[chest.unit_number] = selected_item
                player.print("Item saved for chest: " .. selected_item)
            end
        else
            player.print("No item selected1.")
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]

    for _, child in pairs(player.gui.left.children) do
        if child.name == "custom_chest_gui" then
            child.destroy()
            break
        end
    end
end)

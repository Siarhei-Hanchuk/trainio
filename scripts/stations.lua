local function add_chest_to_station(entity)
    local surface = entity.surface
    local position = entity.position

    local chest_position;

    if entity.direction == 0 then --SN
        chest_position = {x = position.x - 1, y = position.y - 1}
    elseif entity.direction == 2 then --WE
        chest_position = {x = position.x + 0, y = position.y - 1}
    elseif entity.direction == 4 then --NS
        chest_position = {x = position.x + 0, y = position.y + 0}
    elseif entity.direction == 6 then --EW
        chest_position = {x = position.x - 1, y = position.y + 0}
    else
        print("error")
    end

    if surface.can_place_entity{name = "storage-chest", position = chest_position} then
        local chest = surface.create_entity{
            name = "storage-chest",
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


    if surface.can_place_entity{name = "storage-chest", position = chest_position} then
        local chest = surface.create_entity{
            name = "storage-chest",
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

    if entity.name == "train-stop-from-train" or entity.name == "train-stop-to-train" then
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
                -- global.source_chests[chest.unit_number] = nil
                chest.destroy()
            else
                chest.minable = true
            end
        end
        global.linked_chests[entity.unit_number] = nil
        -- if chest.valid then
        --     global.source_chests[chest.unit_number] = nil
        -- end
    end
end

script.on_event(defines.events.on_entity_died, function(event)
    remove_linked_chest(event.entity)
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    remove_linked_chest(event.entity)
end)

script.on_event(defines.events.on_robot_mined_entity, function(event)
    remove_linked_chest(event.entity)
end)

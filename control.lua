local radius = 10
local tick_interval = 60

local function on_nth_tick(event)
    local surfaces = game.surfaces

    for _, surface in pairs(surfaces) do
        local radars = surface.find_entities_filtered{name = "gun-turret"}

        for _, radar in pairs(radars) do
            local center_position = radar.position

            local containers = surface.find_entities_filtered{
                area = {{center_position.x - radius, center_position.y - radius}, {center_position.x + radius, center_position.y + radius}},
                type = "container"
            }

            local wagons = surface.find_entities_filtered{
                area = {{center_position.x - radius, center_position.y - radius}, {center_position.x + radius, center_position.y + radius}},
                type = "cargo-wagon"
            }

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
    end
end

script.on_nth_tick(tick_interval, on_nth_tick)
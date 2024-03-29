local radius = 10
local tick_interval = 60  
local function on_nth_tick(event)
    local surfaces = game.surfaces
    
    for _, surface in pairs(surfaces) do
        
        local radars = surface.find_entities_filtered{name = "gun-turret"}
            
        for _, radar in pairs(radars) do
            
            local center_position = radar.position
            
            local entities = surface.find_entities_filtered{
                area = {{center_position.x - radius, center_position.y - radius}, {center_position.x + radius, center_position.y + radius}},
                type = "container"
            }
            
            for _, entity in pairs(entities) do
                
                if entity.type == "container" then
                    
                    entity.clear_items_inside()
                end
            end
        end
    end
end

script.on_nth_tick(tick_interval, on_nth_tick)
local railWorld = table.deepcopy(data.raw["map-gen-presets"]["default"]["rail-world"])
local preset = table.deepcopy(data.raw["map-gen-presets"]["default"]["default"])

for name, params in pairs(railWorld["basic_settings"]["autoplace_controls"]) do
    if name == "enemy-base" then
        params["frequency"] = 0
    else
        params["frequency"] = 0.16666667
        params["size"] = 6
        params["richness"] = 6
    end
end

cliff_settings = {
    name = "cliff",
    cliff_elevation_interval = 0,
    cliff_elevation_0 = 0
}
pollution = {
    enabled = false,
}

preset["default"] = false
preset["basic_settings"] = {}
preset["advanced_settings"] = {}
preset["basic_settings"]["cliff_settings"] = cliff_settings
preset["advanced_settings"]["pollution"] = pollution
preset["basic_settings"]["autoplace_controls"] = railWorld["basic_settings"]["autoplace_controls"]

data.raw["map-gen-presets"].default["trainio"] = preset

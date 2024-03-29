local railWorld = table.deepcopy(data.raw["map-gen-presets"]["default"]["rail-world"])

for name, params in pairs(railWorld["basic_settings"]["autoplace_controls"]) do
    if name == "enemy-base" then
        params["frequency"] = 0
    else
        params["frequency"] = 0.16666667
        params["size"] = 6
        params["richness"] = 6
    end
end

data.raw["map-gen-presets"].default["trainio"] = railWorld

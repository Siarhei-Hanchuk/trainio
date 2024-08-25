local burnerMiner = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
local electricMiner = table.deepcopy(data.raw["mining-drill"]["electric-mining-drill"])

burnerMiner.selection_box = {{-1.5, -1.5 - 1}, {1.5, 1.5}}
burnerMiner.collision_box = {{-1.5, -1.5 - 1}, {1.5, 1.5}}

electricMiner.selection_box = {{-1.4, -1.4 - 2}, {1.4, 1.4}}
electricMiner.collision_box = {{-1.5, -1.5 - 2}, {1.5, 1.5}}


data:extend{
    burnerMiner,
    electricMiner,
}

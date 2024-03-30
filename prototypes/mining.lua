require("utils.utils")

local BURNER_MINER_PERFORMANCE = 200

local burnerMiner = table.deepcopy(data.raw["mining-drill"]["burner-mining-drill"])
local electricMiner = table.deepcopy(data.raw["mining-drill"]["electric-mining-drill"])

burnerMiner.mining_speed = burnerMiner.mining_speed * BURNER_MINER_PERFORMANCE
burnerMiner.resource_searching_radius = burnerMiner.resource_searching_radius * 2
update_energy_usage(burnerMiner, BURNER_MINER_PERFORMANCE)

burnerMiner.radius_visualisation_picture = table.deepcopy(electricMiner.radius_visualisation_picture)

electricMiner.mining_speed = electricMiner.mining_speed * BURNER_MINER_PERFORMANCE * 2
electricMiner.resource_searching_radius = electricMiner.resource_searching_radius * 5
update_energy_usage(electricMiner, BURNER_MINER_PERFORMANCE * 2)


data:extend{
    burnerMiner, electricMiner, electricFurnace,
}

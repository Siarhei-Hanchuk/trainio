local storageChest = flib.copy_prototype(data.raw["container"]["steel-chest"], "storage-chest")

storageChest.next_upgrade = nil
storageChest.minable = nil
storageChest.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
storageChest.selection_priority = (storageChest.selection_priority or 50) + 10
storageChest.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
storageChest.collision_mask = {"rail-layer"}


local decider_combinator = flib.copy_prototype(data.raw["decider-combinator"]["decider-combinator"], "station-decider-combinator")

decider_combinator.energy_source = {type = "void"}

decider_combinator.next_upgrade = nil
decider_combinator.minable = nil
decider_combinator.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
decider_combinator.selection_priority = (storageChest.selection_priority or 50) + 10
decider_combinator.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
decider_combinator.collision_mask = {"rail-layer"}


data:extend{
    storageChest, decider_combinator
}

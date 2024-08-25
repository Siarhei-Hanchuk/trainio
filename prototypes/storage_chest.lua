local storageChest = flib.copy_prototype(data.raw["container"]["steel-chest"], "storage-chest")

storageChest.next_upgrade = nil
storageChest.minable = nil
storageChest.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
storageChest.selection_priority = (storageChest.selection_priority or 50) + 10
storageChest.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
storageChest.collision_mask = {"rail-layer"}

data:extend{
    storageChest
}

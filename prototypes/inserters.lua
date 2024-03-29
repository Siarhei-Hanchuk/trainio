local inserter = table.deepcopy(data.raw["inserter"]["inserter"])

inserter.extenstion_speed = 0.07
inserter.rotation_speed = 0.04

data:extend{
    inserter,
}


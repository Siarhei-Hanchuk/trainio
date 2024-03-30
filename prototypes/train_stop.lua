local trainStop = table.deepcopy(data.raw["train-stop"]["train-stop"])

trainStop.circuit_wire_max_distance = 25

data:extend{
    trainStop,
}
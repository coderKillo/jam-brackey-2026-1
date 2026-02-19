class_name AbilityManager
extends Node

@export var couch_model: CouchModel

var slot_count := 3
var abilites := [
	{
		shape = TargetGrid.Shapes.CROSS_DIAGONAL,
		range = 4,
		cooldown = 5,
	},
	{
		shape = TargetGrid.Shapes.CROSS,
		range = 4,
		cooldown = 5,
	},
	{
		shape = TargetGrid.Shapes.RING,
		range = 4,
		cooldown = 5,
	}
]


func setup():
	Events.slot_count_changed.emit(slot_count)

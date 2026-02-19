class_name AbilityManager
extends Node

enum Ability {
	SHOOT,
	LASER,
	DASH,
	HOOK,
	BLINK,
	PUSH,
	SHIELD,
	CREATE,
	EMPTY,
	PLAYER,
}


class Slot:
	var ability := Ability.EMPTY
	var cooldown := 0


@export var couch_model: CouchModel
@export var slot_count: int = 10

var _slots: Array[Slot]
var _db := {
	Ability.SHOOT:
	{
		shape = TargetGrid.Shapes.RECT,
		range = 4,
		cooldown = 5,
	},
	Ability.LASER:
	{
		shape = TargetGrid.Shapes.CROSS,
		range = 6,
		cooldown = 5,
	},
	Ability.DASH:
	{
		shape = TargetGrid.Shapes.CROSS,
		range = 4,
		cooldown = 5,
	},
	Ability.HOOK:
	{
		shape = TargetGrid.Shapes.CROSS_DIAGONAL,
		range = 4,
		cooldown = 5,
	},
	Ability.BLINK:
	{
		shape = TargetGrid.Shapes.RING,
		range = 4,
		cooldown = 5,
	},
	Ability.PUSH:
	{
		shape = TargetGrid.Shapes.NONE,
		range = 0,
		cooldown = 10,
	},
	Ability.SHIELD:
	{
		shape = TargetGrid.Shapes.NONE,
		range = 0,
		cooldown = 4,
	},
	Ability.CREATE:
	{
		shape = TargetGrid.Shapes.RECT,
		range = 5,
		cooldown = 5,
	},
}


func _ready():
	GameManager.state_changed.connect(_on_state_changed)


func setup():
	Events.slot_count_changed.emit(slot_count)
	couch_model.setup(slot_count)

	for i in range(slot_count):
		_slots.append(Slot.new())

	_set_ability(Ability.PLAYER, floori(slot_count / 2.0))

	## TODO: remove this, just for testing
	_set_ability(Ability.SHOOT, 0)
	_set_ability(Ability.LASER, 1)
	_set_ability(Ability.DASH, 2)
	_set_ability(Ability.SHIELD, 3)
	_set_ability(Ability.HOOK, 6)
	_set_ability(Ability.BLINK, 7)
	_set_ability(Ability.PUSH, 8)
	_set_ability(Ability.CREATE, 9)

	reset()


func select_slot(slot_index: int):
	couch_model.select(slot_index, is_slot_valid(slot_index))


func get_ability(slot_index: int) -> Dictionary:
	if not is_slot_valid(slot_index):
		return {
			shape = TargetGrid.Shapes.NONE,
			range = 0,
			cooldown = 0,
		}

	return _db[_slots[slot_index].ability]


func is_slot_valid(slot_index: int):
	if slot_index < 0 || slot_index >= slot_count:
		return false
	return _db.has(_slots[slot_index].ability)


func _set_ability(ability: Ability, slot_index: int):
	if slot_index < 0 || slot_index >= slot_count:
		return

	_slots[slot_index].ability = ability

	if _db.has(ability):
		_slots[slot_index].cooldown = _db[ability].cooldown
	else:
		_slots[slot_index].cooldown = 0


func _on_state_changed(_new_state: Global.GameState):
	if _new_state == Global.GameState.ENEMY_TURN:
		reset()


func reset():
	couch_model.reset()

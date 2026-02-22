class_name AbilityManager
extends Node

###

#SHOOT: SOLDIER
#LASER: ENGINEER
#DASH: PILOT
#HOOK: SMUGGLER
#BLINK: NAVIGATOR
#PUSH: PSYKER
#SHIELD: SCIENTIST
#CREATE: OUTLANDER

###

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

signal slot_index_changed(index: int)
signal slots_changed


class Slot:
	var ability := Ability.EMPTY
	var cooldown := 0


@export var slot_count: int = 3

var _slots: Array[Slot]
var _db := {
	Ability.SHOOT:
	{
		ability = Ability.SHOOT,
		shape = TargetGrid.Shapes.RECT,
		texture = preload("res://assets/characters/soldier.png"),
		range = 3,
		cooldown = 4,
		name = "The Soldier",
		description = "Old veteran of many wars, hits enemies"
	},
	Ability.LASER:
	{
		ability = Ability.LASER,
		shape = TargetGrid.Shapes.CROSS,
		texture = preload("res://assets/characters/engineer.png"),
		range = 6,
		cooldown = 3,
		name = "The Engineer",
		description = "Brilliant thinker that can build laser guns and firing them"
	},
	Ability.DASH:
	{
		ability = Ability.DASH,
		shape = TargetGrid.Shapes.CROSS,
		texture = preload("res://assets/characters/pilot.png"),
		range = 3,
		cooldown = 4,
		name = "The Pilot",
		description =
		"Expierent pilot that travel large distances with ease and crushes enemies in his path"
	},
	Ability.HOOK:
	{
		ability = Ability.HOOK,
		shape = TargetGrid.Shapes.CROSS_DIAGONAL,
		texture = preload("res://assets/characters/smuggler.png"),
		range = 4,
		cooldown = 2,
		name = "The Smuggler",
		description =
		"Years in the business taugth him how get what he wants, can pull enemies to you"
	},
	Ability.BLINK:
	{
		ability = Ability.BLINK,
		shape = TargetGrid.Shapes.RING,
		texture = preload("res://assets/characters/navigator.png"),
		range = 3,
		cooldown = 4,
		name = "The Navigator",
		description = "Can find wormholes to teleport you to a close location"
	},
	Ability.PUSH:
	{
		ability = Ability.PUSH,
		shape = TargetGrid.Shapes.NONE,
		texture = preload("res://assets/characters/psyker.png"),
		range = 2,
		cooldown = 3,
		name = "The Psyker",
		description = "Born with a mind that can control energy, can push enemies away"
	},
	Ability.SHIELD:
	{
		ability = Ability.SHIELD,
		shape = TargetGrid.Shapes.NONE,
		texture = preload("res://assets/characters/scientist.png"),
		range = 2,
		cooldown = 3,
		name = "The Scientist",
		description = "Crazy thinker that always carries his shield genertor with him"
	},
	Ability.CREATE:
	{
		ability = Ability.CREATE,
		shape = TargetGrid.Shapes.RECT,
		texture = preload("res://assets/characters/outlander.png"),
		range = 4,
		cooldown = 4,
		name = "The Outlander",
		description = "His ability to create matter is unlike any other"
	},
	Ability.PLAYER:
	{
		ability = Ability.PLAYER,
		shape = TargetGrid.Shapes.NONE,
		texture = preload("res://assets/characters/player.png"),
		range = 0,
		cooldown = 0,
		name = "The Adventurer",
		description = "Just you"
	},
}


func _ready():
	GameManager.state_changed.connect(_on_state_changed)


func setup():
	for i in range(slot_count):
		_slots.append(Slot.new())

	_set_ability(Ability.PLAYER, floori(slot_count / 2.0))

	Events.slot_count_changed.emit(slot_count)
	reset()


func update_slot_count(new_count: int):
	if new_count == slot_count:
		return

	if new_count < slot_count:
		slot_count = new_count
		setup()
	else:
		for i in new_count - slot_count:
			_slots.append(Slot.new())
		slot_count = new_count
	Events.slot_count_changed.emit(slot_count)


func select_slot(slot_index: int):
	slot_index_changed.emit(slot_index)


func add_ability(ability: Ability) -> bool:
	for slot_index in slot_count:
		if _slots[slot_index].ability == Ability.EMPTY:
			_set_ability(ability, slot_index)
			return true
	return false


func free_random_slot() -> bool:
	var slots_with_abilites = []
	for slot_index in slot_count:
		if _slots[slot_index].ability in [Ability.EMPTY, Ability.PLAYER]:
			continue
		slots_with_abilites.append(slot_index)

	if slots_with_abilites.is_empty():
		return false
	var freed_slot = slots_with_abilites.pick_random()
	Events.ability_lost.emit(_slots[freed_slot].ability)
	_slots[freed_slot] = Slot.new()
	slots_changed.emit()
	return true


func cast_ability(slot_index: int):
	_slots[slot_index].cooldown = get_ability(slot_index).cooldown + 1
	slots_changed.emit()


func get_ability(slot_index: int) -> Dictionary:
	if not is_slot_valid(slot_index):
		return {
			ability = Ability.EMPTY,
			shape = TargetGrid.Shapes.NONE,
			texture = Texture.new(),
			range = 0,
			cooldown = 0,
			name = "",
			description = "",
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
	_slots[slot_index].cooldown = 0


func _on_state_changed(_new_state: Global.GameState):
	if _new_state == Global.GameState.ENEMY_TURN:
		reset()
		for slot in _slots:
			if slot.cooldown > 0:
				slot.cooldown -= 1
		slots_changed.emit()


func reset():
	slot_index_changed.emit(-1)

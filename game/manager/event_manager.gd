class_name EventManager
extends Node

var available_abilies = [
	AbilityManager.Ability.SHOOT,
	AbilityManager.Ability.LASER,
	AbilityManager.Ability.DASH,
	AbilityManager.Ability.HOOK,
	AbilityManager.Ability.BLINK,
	AbilityManager.Ability.PUSH,
	AbilityManager.Ability.SHIELD,
	AbilityManager.Ability.CREATE,
]

var event_ability = AbilityManager.Ability.EMPTY


func _ready():
	Events.ability_lost.connect(_on_ability_lost)


func setup():
	pass


func play_event():
	if available_abilies.is_empty():
		return
	event_ability = available_abilies.pick_random()
	available_abilies.erase(event_ability)


func _on_ability_lost(ability: AbilityManager.Ability):
	available_abilies.append(ability)

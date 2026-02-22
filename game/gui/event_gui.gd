extends Control

@export var event_manager: EventManager
@export var ability_manager: AbilityManager

@onready var title_label: Label = $VBoxContainer/Title
@onready var body_label: RichTextLabel = $VBoxContainer/HBoxContainer/Body
@onready var image: TextureRect = $VBoxContainer/HBoxContainer/Image


func _ready():
	assert(event_manager)
	assert(ability_manager)
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(state: Global.GameState):
	if state != Global.GameState.WAIT_FOR_EVENT_INPUT:
		hide()
		return
	if not ability_manager._db.has(event_manager.event_ability):
		return

	show()

	var ability = ability_manager._db[event_manager.event_ability]
	title_label.text = ability.name
	body_label.text = ability.description
	body_label.text += "\nrange: " + str(ability.range) + " tiles"
	body_label.text += "\ncooldown: " + str(ability.cooldown) + " turns"
	image.texture = ability.texture

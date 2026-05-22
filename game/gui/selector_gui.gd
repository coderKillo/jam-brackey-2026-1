extends PanelContainer

@export var ability_manager: AbilityManager
@export var input_manager: InputManager

@onready var title_label: Label = $MarginContainer/VBoxContainer/Title
@onready var body_label: RichTextLabel = $MarginContainer/VBoxContainer/Body


func _ready():
	assert(ability_manager)
	assert(input_manager)

	input_manager.input_received.connect(_on_input_received)
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_input_received():
	if GameManager.current_state != Global.GameState.PLAYER_TURN:
		hide()
		return

	if input_manager.current_mode == InputManager.Mode.MOVEMENT:
		hide()
		return

	var slot = input_manager.ability_selected
	if not ability_manager.is_slot_valid(slot):
		hide()
		return

	var ability = ability_manager.get_ability(slot)
	title_label.text = ability.name
	body_label.text = ability.description
	body_label.text += "\nrange: " + str(ability.range) + " tiles"
	body_label.text += "\ncooldown: " + str(ability.cooldown) + " turns"

	show()


func _on_game_state_changed(state: Global.GameState):
	if state != Global.GameState.PLAYER_TURN:
		hide()

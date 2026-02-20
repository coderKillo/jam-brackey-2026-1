extends Control

@export var ability_manager: AbilityManager
@export var input_manager: InputManager

@onready var movement: Control = $MovementState
@onready var select_ability: Control = $SelectAbility
@onready var select_target: Control = $SelectTarget


func _ready():
	assert(ability_manager)
	assert(input_manager)

	input_manager.input_received.connect(_on_input_received)
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_input_received():
	movement.hide()
	select_ability.hide()
	select_target.hide()

	match input_manager.current_mode:
		InputManager.Mode.MOVEMENT:
			movement.show()
		InputManager.Mode.SELECT_ABILITY:
			select_ability.show()
		InputManager.Mode.SELECT_CELL:
			select_target.show()


func _on_game_state_changed(state: Global.GameState):
	if state != Global.GameState.WAIT_FOR_COMBAT_INPUT:
		movement.hide()
		select_ability.hide()
		select_target.hide()

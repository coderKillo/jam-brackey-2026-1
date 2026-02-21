class_name InputManager
extends Node

enum Mode {
	MOVEMENT,
	SELECT_ABILITY,
	SELECT_CELL,
	CAST_ABILITY,
	EVENT,
	ACCEPT,
	REJECT,
}

signal input_received

var ability_selected := 0:
	set(value):
		if value != ability_selected:
			ability_selected = value
			input_received.emit()

var direction := Vector2i.ZERO:
	set(value):
		direction = value
		input_received.emit()

var current_mode := Mode.MOVEMENT:
	set(value):
		if value != current_mode:
			direction = Vector2i.ZERO
			current_mode = value
			input_received.emit()

var _slot_count: int = 0
var _active: bool = false


func _ready():
	Events.slot_count_changed.connect(func(count: int): _slot_count = count)
	GameManager.state_changed.connect(_on_game_state_changed)


func setup() -> void:
	reset()


func reset():
	current_mode = Mode.MOVEMENT
	direction = Vector2i.ZERO


func _process(_delta):
	if not _active:
		return

	match current_mode:
		Mode.MOVEMENT:
			if Input.is_action_just_pressed("move_right"):
				direction = Vector2i.RIGHT
			elif Input.is_action_just_pressed("move_left"):
				direction = Vector2i.LEFT
			elif Input.is_action_just_pressed("move_up"):
				direction = Vector2i.UP
			elif Input.is_action_just_pressed("move_down"):
				direction = Vector2i.DOWN
			elif Input.is_action_just_pressed("action"):
				current_mode = Mode.SELECT_ABILITY

		Mode.SELECT_ABILITY:
			if Input.is_action_just_pressed("move_right"):
				ability_selected = (ability_selected + 1) % _slot_count
			elif Input.is_action_just_pressed("move_left"):
				ability_selected = (ability_selected - 1 + _slot_count) % _slot_count
			elif Input.is_action_just_pressed("action"):
				current_mode = Mode.SELECT_CELL
			elif Input.is_action_just_pressed("cancel"):
				cancel()

		Mode.SELECT_CELL:
			if Input.is_action_just_pressed("move_right"):
				direction = Vector2i.RIGHT
			elif Input.is_action_just_pressed("move_left"):
				direction = Vector2i.LEFT
			elif Input.is_action_just_pressed("move_up"):
				direction = Vector2i.UP
			elif Input.is_action_just_pressed("move_down"):
				direction = Vector2i.DOWN
			elif Input.is_action_just_pressed("action"):
				current_mode = Mode.CAST_ABILITY
			elif Input.is_action_just_pressed("cancel"):
				cancel()

		Mode.EVENT:
			if Input.is_action_just_pressed("action"):
				current_mode = Mode.ACCEPT
			elif Input.is_action_just_pressed("cancel"):
				current_mode = Mode.REJECT


func _on_game_state_changed(state: Global.GameState):
	match state:
		Global.GameState.WAIT_FOR_COMBAT_INPUT:
			reset()
			current_mode = Mode.MOVEMENT
			_active = true
		Global.GameState.WAIT_FOR_EVENT_INPUT:
			reset()
			current_mode = Mode.EVENT
			_active = true
		_:
			_active = false


func cancel():
	if not _active:
		return
	match current_mode:
		Mode.SELECT_ABILITY:
			current_mode = Mode.MOVEMENT

		Mode.SELECT_CELL:
			current_mode = Mode.SELECT_ABILITY

class_name InputManager
extends Node

signal input_received

var ability := 0
var direction := Vector2.ZERO


func setup():
	pass


func _process(_delta):
	if GameManager.current_state != Global.GameState.WAIT_FOR_COMBAT_INPUT:
		return

	direction = Vector2.ZERO
	ability = 0

	if Input.is_action_pressed("move_right"):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed("move_left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("move_up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		direction = Vector2.DOWN

	if direction != Vector2.ZERO:
		input_received.emit()

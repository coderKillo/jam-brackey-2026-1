class_name Player
extends Sprite2D

signal turn_finished

var shield_value := 0
var start_position := Vector2i.ZERO

@onready var shield: Sprite2D = $Shield
@onready var projectile: Node2D = $Projectile

var _grid: Grid
var _input: InputManager


func setup(grid: Grid, input: InputManager):
	_grid = grid
	_input = input


func spawn():
	reset()


func turn():
	# TODO: implement player turn logic

	while true:
		await _input.input_received
		var moved = await _grid.move(self, _input.direction)
		print(moved)
		if moved:
			break
	await get_tree().create_timer(0.2).timeout
	turn_finished.emit()


func reset():
	projectile.hide()

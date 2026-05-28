class_name Player
extends Sprite2D

signal turn_finished

var shield_value := 0
var start_position := Vector2i.ZERO

@onready var shield: Sprite2D = $Shield
@onready var projectile: Node2D = $Projectile

var _grid: Grid
var _target_grid: TargetGrid
var _input: InputManager


func setup(grid: Grid, target_grid: TargetGrid, input: InputManager):
	_grid = grid
	_target_grid = target_grid
	_input = input


func spawn():
	reset()


func turn():
	# TODO: implement player turn logic
	var player_position = _grid.get_coords(self)
	var distance = 1

	_target_grid.active()

	while true:
		_input.active(true)
		_target_grid.make_shape(TargetGrid.Shapes.CROSS, player_position, distance)

		await _input.input_received
		if _input.is_cell_selected():
			var cell_position := _input.get_cell_position()
			var diff = abs(cell_position - player_position)
			if (diff.y != 0 and diff.x != 0) or (diff.y != distance and diff.x != distance):
				continue

			var move = await _grid.move_to(self, cell_position)
			if move:
				break

		if _input.is_slot_selected():
			distance += 1

	_target_grid.reset()
	await get_tree().create_timer(0.2).timeout
	turn_finished.emit()


func reset():
	projectile.hide()

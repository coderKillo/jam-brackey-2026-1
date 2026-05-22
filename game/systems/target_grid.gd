class_name TargetGrid
extends TileMapLayer

const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DIRECTIONS_DIAGONAL = [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(1, -1)]
const SELECTION_VALID = 0
const SELECTION_INVALID = 1

enum Shapes { NONE, RING, RECT, CROSS, CROSS_DIAGONAL }

@onready var selector: Sprite2D = $Selector

var current_shape = Shapes.NONE
var size: int = 3
var selector_position: Vector2i = Vector2i.ZERO

var _grid: Grid
var _current_shape := Shapes.NONE
var _position_lookup = {}
var _current_direction := Vector2i.ZERO


func setup(grid: Grid):
	_grid = grid


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: Global.GameState):
	if new_state != Global.GameState.PLAYER_TURN:
		reset()


func _process(_delta):
	selector.position = lerp(selector.position, map_to_local(selector_position), 0.2)


func make_shape(shape: Shapes, coord: Vector2i, distance: int):
	clear()
	_position_lookup.clear()
	_current_shape = shape

	selector.frame = SELECTION_INVALID
	selector_position = coord

	match shape:
		Shapes.RING:
			for cell in _grid.get_used_cells():
				if _grid.is_obstical(cell):
					continue
				var diff = abs(cell - coord)
				var distance_to_cell = diff.x + diff.y
				if distance_to_cell <= 1 or distance_to_cell > distance:
					continue
				add_target_tile(cell)

			selector.frame = SELECTION_INVALID
			selector_position = coord

		Shapes.RECT:
			for x in range(-distance, distance):
				for y in range(-distance, distance):
					if abs(x) <= 1 and abs(y) <= 1:
						continue
					if (abs(x) + abs(y)) >= (distance * 2 - 1):
						continue
					var cell_pos = coord + Vector2i(x, y)
					if not _grid.is_within_bounds(cell_pos) or _grid.is_obstical(cell_pos):
						continue
					add_target_tile(cell_pos)

		Shapes.CROSS:
			for direction in DIRECTIONS:
				var result = _grid.raycast(coord, direction, distance)
				for cell_pos in result:
					add_target_tile(cell_pos)
				if not result.is_empty():
					_position_lookup[direction] = result.back()
					_current_direction = direction
					selector_position = result.back()
					selector.frame = SELECTION_VALID

		Shapes.CROSS_DIAGONAL:
			for direction in DIRECTIONS_DIAGONAL:
				var result = _grid.raycast(coord, direction, distance)
				for cell_pos in result:
					add_target_tile(cell_pos)
				if not result.is_empty():
					_position_lookup[direction] = result.back()
					_current_direction = direction
					selector_position = result.back()
					selector.frame = SELECTION_VALID

		Shapes.NONE:
			pass

	selector.hide()


func move_selector(direction: Vector2i):
	if direction == Vector2i.ZERO:
		selector.show()

	match _current_shape:
		Shapes.RING:
			_move_selector_on_grid(direction)

		Shapes.RECT:
			_move_selector_on_grid(direction)

		Shapes.CROSS:
			_move_selector_direction(direction)

		Shapes.CROSS_DIAGONAL:
			_move_selector_cross_direction(direction)

		Shapes.NONE:
			pass


func _move_selector_on_grid(direction: Vector2i):
	var new_pos = selector_position + direction
	if not _grid.is_within_bounds(new_pos):
		return
	selector.show()
	selector_position = new_pos
	if is_target_tile(selector_position):
		selector.frame = SELECTION_VALID
	else:
		selector.frame = SELECTION_INVALID


func _move_selector_direction(direction: Vector2i):
	if not _position_lookup.has(direction):
		return
	selector.frame = SELECTION_VALID
	selector.show()
	selector_position = _position_lookup[direction]
	_current_direction = direction


func _move_selector_cross_direction(direction: Vector2i):
	var new_direction = _current_direction
	if direction.x != 0:
		new_direction.x = direction.x
	if direction.y != 0:
		new_direction.y = direction.y

	if not _position_lookup.has(new_direction):
		return

	selector.frame = SELECTION_VALID
	selector.show()
	selector_position = _position_lookup[new_direction]
	_current_direction = new_direction


func add_target_tile(pos: Vector2i):
	set_cell(pos, 0, Vector2i.ZERO)


func is_target_tile(pos: Vector2i):
	return get_cell_atlas_coords(pos) == Vector2i.ZERO


func reset():
	selector.hide()
	clear()

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


func setup(grid: Grid):
	_grid = grid


func _ready():
	GameManager.state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(new_state: Global.GameState):
	if new_state != Global.GameState.WAIT_FOR_COMBAT_INPUT:
		reset()


func _process(_delta):
	selector.position = lerp(selector.position, map_to_local(selector_position), 0.2)


func make_shape(shape: Shapes, coord: Vector2i, distance: int):
	clear()

	match shape:
		Shapes.RING:
			for cell in _grid.get_free_cells():
				var diff = abs(cell - coord)
				var distance_to_cell = diff.x + diff.y
				if distance_to_cell <= 1 or distance_to_cell > distance:
					continue
				add_target_tile(cell)

		Shapes.RECT:
			for x in range(-distance, distance):
				for y in range(-distance, distance):
					if abs(x) <= 1 and abs(y) <= 1:
						continue
					if (abs(x) + abs(y)) >= (distance * 2 - 1):
						continue
					var cell_pos = coord + Vector2i(x, y)
					if not _grid.is_within_bounds(cell_pos) or _grid.is_cell_blocked(cell_pos):
						continue
					add_target_tile(cell_pos)

		Shapes.CROSS:
			for direction in DIRECTIONS:
				raycast(coord, direction, distance)

		Shapes.CROSS_DIAGONAL:
			for direction in DIRECTIONS_DIAGONAL:
				raycast(coord, direction, distance)

		Shapes.NONE:
			pass

	selector.hide()
	selector.frame = SELECTION_INVALID
	selector_position = coord


func move_selector(direction: Vector2i):
	var new_pos = selector_position + direction
	if not _grid.is_within_bounds(new_pos):
		return
	selector.show()
	selector_position = new_pos
	if is_target_tile(selector_position):
		selector.frame = SELECTION_VALID
	else:
		selector.frame = SELECTION_INVALID


func raycast(start: Vector2i, direction: Vector2i, length: int):
	for i in length:
		var cell_pos = start + direction * (i + 1)
		if not _grid.is_within_bounds(cell_pos) or _grid.is_cell_blocked(cell_pos):
			return
		add_target_tile(cell_pos)


func add_target_tile(pos: Vector2i):
	set_cell(pos, 0, Vector2i.ZERO)


func is_target_tile(pos: Vector2i):
	return get_cell_atlas_coords(pos) == Vector2i.ZERO


func reset():
	selector.hide()
	selector_position = Vector2i.ZERO
	clear()

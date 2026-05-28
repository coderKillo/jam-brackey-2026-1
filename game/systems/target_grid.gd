class_name TargetGrid
extends TileMapLayer

signal cell_selected(pos: Vector2i)

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
	reset()


func _ready():
	$MouseDetection.input_event.connect(_on_input_event)
	$MouseDetection.mouse_entered.connect(_on_mouse_entered)
	$MouseDetection.mouse_exited.connect(_on_mouse_exited)


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


func add_target_tile(pos: Vector2i):
	set_cell(pos, 0, Vector2i.ZERO)


func is_target_tile(pos: Vector2i):
	return get_cell_atlas_coords(pos) == Vector2i.ZERO


func reset():
	hide()
	clear()


func active():
	show()


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseMotion:
		selector_position = local_to_map(to_local(event.position))
		selector.show()
		if is_target_tile(selector_position):
			selector.frame = SELECTION_VALID
		else:
			selector.frame = SELECTION_INVALID

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			cell_selected.emit(selector_position)


func _on_mouse_entered():
	selector.show()


func _on_mouse_exited():
	selector.hide()

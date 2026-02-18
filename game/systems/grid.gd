class_name Grid
extends TileMapLayer

signal entity_moved
signal level_generated

@export var ground_atlas_coords: Vector2i
@export var blocked_atlas_coords: Vector2i

var gird_size := Vector2i.ZERO


func generate_level(size: Vector2i):
	gird_size = size
	reset()
	var half_size = size / 2
	for x in range(-half_size.x, half_size.x):
		for y in range(-half_size.y, half_size.y):
			set_cell(Vector2i(x, y), 0, ground_atlas_coords)
	await get_tree().create_timer(0.2).timeout
	level_generated.emit()


func reset():
	clear()


func add(
	entity: Node2D, start_position: Vector2i = Vector2i(0, 0), block_cell: bool = true
) -> bool:
	if is_cell_blocked(start_position) or not is_within_bounds(start_position):
		var free_cells := get_free_cells()
		if free_cells.is_empty():
			return false
		start_position = free_cells.pick_random()

	entity.position = map_to_local(start_position)
	if block_cell:
		set_cell(start_position, 0, blocked_atlas_coords)
	return true


func move(entity: Node2D, direction: Vector2i) -> bool:
	await get_tree().create_timer(0.2).timeout
	var old_pos = local_to_map(entity.position)
	var new_pos = old_pos + direction
	if not is_within_bounds(new_pos):
		entity_moved.emit()
		return false

	if is_cell_blocked(new_pos):
		entity_moved.emit()
		return false

	set_cell(old_pos, 0, ground_atlas_coords)
	entity.position = map_to_local(new_pos)
	set_cell(new_pos, 0, blocked_atlas_coords)
	entity_moved.emit()
	return true


func get_coords(entity: Node2D) -> Vector2i:
	return local_to_map(entity.position)


func get_free_cells() -> Array[Vector2i]:
	return get_used_cells().filter(func(coords): return not is_cell_blocked(coords))


func is_cell_blocked(coords: Vector2i) -> bool:
	return get_cell_atlas_coords(coords) == blocked_atlas_coords


func is_within_bounds(coords: Vector2i) -> bool:
	return get_cell_source_id(coords) >= 0

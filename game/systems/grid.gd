class_name Grid
extends TileMapLayer

const SPAWN_FEEDBACK_FRAME = 3

signal entity_moved
signal entity_spawned
signal level_generated

@export var ground_atlas_coords: Vector2i
@export var unit_atlas_coords: Vector2i
@export var obstical_atlas_coords: Vector2i
@export var obstical_random_image: Image

@onready var player: Player = %Player
@onready var portal: Portal = %Portal
@onready var stranger: Stranger = %Stranger

var gird_size := Vector2i.ZERO


func generate_level(size: Vector2i):
	gird_size = size
	reset()
	var offset = size / 2
	var top_left = -offset
	var bottom_right = size - offset

	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):
			set_cell(Vector2i(x, y), 0, ground_atlas_coords)

	await get_tree().create_timer(0.2).timeout
	level_generated.emit()


func reset():
	clear()


func add(
	entity: Node2D, start_position: Vector2i = Vector2i(0, 0), block_cell: bool = true
) -> bool:
	if not is_ground(start_position) or not is_within_bounds(start_position):
		var free_cells := get_free_cells()
		if free_cells.is_empty():
			return false
		start_position = free_cells.pick_random()

	entity.position = map_to_local(start_position)
	if block_cell:
		set_cell(start_position, 0, unit_atlas_coords)
	return true


func spawn(entity: Node2D, start_position: Vector2i):
	add(entity, start_position)
	entity.hide()
	await VfxManager.spawn_effect(
		VfxManager.Effect.SPAWN, entity.global_position, SPAWN_FEEDBACK_FRAME
	)
	entity.show()
	entity_spawned.emit()


func move(entity: Node2D, direction: Vector2i) -> bool:
	var old_pos = local_to_map(entity.position)
	var new_pos = old_pos + direction
	var moved = await move_to(entity, new_pos)
	return moved


func move_to(entity: Node2D, new_pos: Vector2i) -> bool:
	var moved = true
	var old_pos = local_to_map(entity.position)

	if not is_within_bounds(new_pos):
		moved = false
		new_pos = old_pos
	if is_obstical(new_pos) or is_unit(new_pos):
		moved = false
		new_pos = old_pos

	set_cell(old_pos, 0, ground_atlas_coords)

	var tween = get_tree().create_tween()
	tween.tween_property(entity, "position", map_to_local(new_pos), 0.2)
	await tween.finished

	set_cell(new_pos, 0, unit_atlas_coords)

	entity_moved.emit()
	return moved


func get_coords(entity: Node2D) -> Vector2i:
	return local_to_map(entity.position)


func raycast(start: Vector2i, direction: Vector2i, length: int) -> Array[Vector2i]:
	var result: Array[Vector2i]
	for i in length:
		var cell_pos = start + direction * (i + 1)
		if not is_within_bounds(cell_pos) or is_obstical(cell_pos):
			break
		result.append(cell_pos)
	return result


func get_free_cells() -> Array[Vector2i]:
	return get_used_cells().filter(func(coords): return is_ground(coords))


func is_obstical(coords: Vector2i) -> bool:
	return get_cell_atlas_coords(coords).y == obstical_atlas_coords.y


func is_ground(coords: Vector2i) -> bool:
	return get_cell_atlas_coords(coords) == ground_atlas_coords


func is_unit(coords: Vector2i) -> bool:
	return get_cell_atlas_coords(coords) == unit_atlas_coords


func is_within_bounds(coords: Vector2i) -> bool:
	return get_cell_source_id(coords) >= 0

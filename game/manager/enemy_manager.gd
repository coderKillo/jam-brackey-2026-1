class_name EnemyManager
extends Node

const MOVEMENT_DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

signal enemies_moved
signal enemies_spawned

@export var enemy_count := 2
@export var enemy_scene: PackedScene

var total_damage := 0

var _grid: Grid
var _player: Player
var _enemies: Array[Node2D]


func setup(grid: Grid, player: Player):
	_grid = grid
	_player = player


func spawn_enemies():
	for i in enemy_count:
		var enemy = enemy_scene.instantiate()
		if _grid.add(enemy):
			_grid.add_child(enemy)
			_enemies.append(enemy)
			enemy.hide()
			await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, enemy.global_position, 3)
			enemy.show()
	await get_tree().create_timer(0.2).timeout
	enemies_spawned.emit()


func clear_enemies():
	for enemy in _enemies:
		enemy.queue_free()
	_enemies.clear()


func take_damage(coords: Vector2i):
	for enemy in _enemies:
		if _grid.get_coords(enemy) == coords:
			_grid.set_cell(coords, 0, _grid.ground_atlas_coords)
			_enemies.erase(enemy)
			VfxManager.spawn_effect(VfxManager.Effect.EXPLOSION, enemy.global_position)
			enemy.queue_free()


func get_enemy(coords: Vector2i) -> Node2D:
	for enemy in _enemies:
		if _grid.get_coords(enemy) == coords:
			return enemy
	return null


func move_enemies():
	var player_pos := _grid.local_to_map(_player.position)

	for _enemy in _enemies:
		var enemy := _enemy as Enemy
		var enemy_pos := _grid.local_to_map(enemy.position)
		var move_direction := Vector2i.ZERO

		for direction in MOVEMENT_DIRECTIONS:
			if direction == enemy.last_movement:
				continue
			var new_pos = enemy_pos + direction
			if not _grid.is_ground(new_pos) or not _grid.is_within_bounds(new_pos):
				continue
			if player_pos.distance_to(new_pos) < player_pos.distance_to(enemy_pos + move_direction):
				move_direction = direction

		if move_direction != Vector2i.ZERO:
			await _grid.move(enemy, move_direction)

		## update position
		enemy_pos = _grid.local_to_map(enemy.position)
		if player_pos in _grid.get_surrounding_cells(enemy_pos):
			await VfxManager.spawn_effect(VfxManager.Effect.SLASH, _player.global_position)
			Events.camera_shake.emit(0.8)
			total_damage += enemy.attack_player()

	await get_tree().create_timer(0.2).timeout
	enemies_moved.emit()

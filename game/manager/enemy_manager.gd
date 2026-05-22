class_name EnemyManager
extends Node

const MOVEMENT_DIRECTIONS := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

signal enemies_turn_finished
signal enemies_plan_finished
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
		var free_cells = _grid.get_free_cells()
		if free_cells.is_empty():
			continue
		_grid.add_child(enemy)
		_grid.spawn(enemy, free_cells.pick_random())
		_enemies.append(enemy)

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
			enemy.death()


func get_enemy(coords: Vector2i) -> Node2D:
	for enemy in _enemies:
		if _grid.get_coords(enemy) == coords:
			return enemy
	return null


func enemy_plan():
	await get_tree().create_timer(0.2).timeout
	enemies_plan_finished.emit()


func enemy_turn():
	for _enemy in _enemies:
		_enemy.turn()
		await _enemy.turn_finished

	await get_tree().create_timer(0.2).timeout
	enemies_turn_finished.emit()

class_name EnemyManager
extends Node

signal enemies_moved
signal enemies_spawned

@export var enemy_count := 2
@export var enemy_scene: PackedScene

var _grid: Grid
var _enemies: Array[Node2D]


func setup(grid: Grid):
	_grid = grid


func spawn_enemies():
	for i in enemy_count:
		var enemy = enemy_scene.instantiate()
		if _grid.add(enemy):
			_grid.add_child(enemy)
			_enemies.append(enemy)
	await get_tree().create_timer(0.2).timeout
	enemies_spawned.emit()


func clear_enemies():
	for enemy in _enemies:
		enemy.queue_free()
	_enemies.clear()


func move_enemies():
	for enemy in _enemies:
		var direction = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
		_grid.move(enemy, direction)
	await get_tree().create_timer(0.2).timeout
	enemies_moved.emit()

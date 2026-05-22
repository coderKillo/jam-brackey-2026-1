# handles transition, level generaton and unit spawning
class_name LevelGenerator
extends Node2D

signal level_generated

const GRID_SIZE = Vector2i(10, 7)

var _background: Background
var _enemy_manager: EnemyManager
var _grid: Grid
var _world: Node2D


func setup(background: Background, enemy_manager: EnemyManager, grid: Grid, world: Node2D):
	_background = background
	_enemy_manager = enemy_manager
	_grid = grid
	_world = world


func generate_level():
	# transition
	await _transition()

	# fill grid
	_grid.generate_level(GRID_SIZE)
	await _grid.level_generated

	#spawn units
	_grid.spawn(_grid.portal, Vector2i(3, 0))
	await _grid.entity_spawned

	_grid.spawn(_grid.stranger, Vector2i(0, 0))
	await _grid.entity_spawned

	_grid.spawn(_grid.player, Vector2i(-4, 0))
	await _grid.entity_spawned

	_enemy_manager.spawn_enemies()
	await _enemy_manager.enemies_spawned

	level_generated.emit()


func _transition():
	var tween = get_tree().create_tween()
	tween.tween_property(_world, "modulate:a", 0.0, 0.2)
	tween.tween_method(_background.set_star_speed, 0.01, 1.0, 0.2)
	tween.tween_method(_background.set_star_speed, 1.0, 0.01, 0.2)
	tween.tween_property(_world, "modulate:a", 1.0, 0.2)
	await tween.finished

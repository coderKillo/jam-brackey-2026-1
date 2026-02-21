class_name Stranger
extends Sprite2D

signal spawned

var start_position := Vector2i.ZERO

var _grid: Grid


func setup(grid: Grid):
	_grid = grid


func spawn():
	_grid.add(self, start_position)
	hide()
	await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, global_position, 3)
	show()
	spawned.emit()

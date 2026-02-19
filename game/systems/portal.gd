class_name Portal
extends Sprite2D

signal spawned

var _grid: Grid


func setup(grid: Grid):
	_grid = grid


func spawn():
	_grid.add(self, Vector2i.ZERO, false)
	hide()
	await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, global_position, 3)
	show()
	spawned.emit()

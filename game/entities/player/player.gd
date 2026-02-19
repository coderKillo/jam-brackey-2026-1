class_name Player
extends Sprite2D

signal spawned

var _grid: Grid


func setup(grid: Grid):
	_grid = grid


func spawn():
	reset()
	_grid.add(self)
	hide()
	await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, global_position, 3)
	show()
	spawned.emit()


func reset():
	pass

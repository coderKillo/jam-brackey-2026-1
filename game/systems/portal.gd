class_name Portal
extends Sprite2D

signal spawned

var _grid: Grid


func setup(grid: Grid):
	_grid = grid


func spawn():
	_grid.add(self, Vector2i.ZERO, false)
	await get_tree().create_timer(0.2).timeout
	spawned.emit()

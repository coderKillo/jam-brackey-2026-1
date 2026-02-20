class_name Player
extends Sprite2D

signal spawned

var shield_value := 0

@onready var shield: Sprite2D = $Shield
@onready var projectile: Node2D = $Projectile

var _grid: Grid


func _process(_delta):
	shield.modulate.a = shield_value / 5.0


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
	projectile.hide()

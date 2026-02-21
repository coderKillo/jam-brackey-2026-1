class_name Player
extends Sprite2D

signal spawned

var shield_value := 0
var start_position := Vector2i.ZERO

@onready var shield: Sprite2D = $Shield
@onready var projectile: Node2D = $Projectile

var _grid: Grid


func _process(_delta):
	shield.modulate.a = shield_value / 5.0


func setup(grid: Grid):
	_grid = grid


func spawn():
	reset()
	_grid.add(self, start_position)
	hide()
	await VfxManager.spawn_effect(VfxManager.Effect.SPAWN, global_position, 3)
	show()
	spawned.emit()


func play_hook(direction: Vector2i, distance: int):
	projectile.show()
	projectile.modulate = Color.BROWN
	projectile.look_at(global_position + Vector2(direction.x, direction.y))
	var tween = get_tree().create_tween()
	tween.tween_property(projectile, "scale:x", distance * Global.CELL_SIZE / 2.0, 0.2)
	tween.tween_property(projectile, "scale:x", 1.0, 0.1)
	await tween.finished
	projectile.hide()


func play_laser(direction: Vector2i, distance: int):
	projectile.show()
	projectile.modulate = Color.WHITE
	projectile.look_at(global_position + Vector2(direction.x, direction.y))
	var tween = get_tree().create_tween()
	tween.tween_property(projectile, "scale:x", distance * Global.CELL_SIZE / 2.0, 0.2)
	tween.tween_property(projectile, "scale:y", 8.0, 0.2)
	tween.tween_interval(0.2)
	tween.tween_property(projectile, "scale:y", 1.0, 0.1)
	await tween.finished
	projectile.hide()


func reset():
	projectile.hide()

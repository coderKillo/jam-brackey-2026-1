extends Node2D

enum Effect { SPAWN }

var _db = {Effect.SPAWN: preload("res://game/vfx/spawn.tscn")}


func spawn_effect(effect: Effect, effect_position: Vector2, feedback_frame: int = -1) -> void:
	if not _db.has(effect):
		return
	var sprite := _db[effect].instantiate() as Vfx
	add_child(sprite)

	sprite.global_position = effect_position
	sprite.z_index = 1
	sprite.play("default")

	if feedback_frame >= 0 and feedback_frame < sprite.sprite_frames.get_frame_count("default"):
		while sprite.frame != feedback_frame:
			await sprite.frame_changed
	else:
		await sprite.animation_finished

class_name Enemy
extends Sprite2D

signal turn_finished

var last_movement := Vector2i.ZERO
var stun := 0


# return damage
func attack_player() -> int:
	return 1


func death():
	VfxManager.spawn_effect(VfxManager.Effect.EXPLOSION, global_position)
	queue_free()


func turn():
	# TODO: implement turn logic
	modulate = Color.BLUE
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE
	turn_finished.emit()

	# var player_pos := _grid.local_to_map(_player.position)
	#
	# for _enemy in _enemies:
	# 	var enemy := _enemy as Enemy
	# 	var enemy_pos := _grid.local_to_map(enemy.position)
	# 	var move_direction := Vector2i.ZERO
	#
	# 	for direction in MOVEMENT_DIRECTIONS:
	# 		if direction == enemy.last_movement:
	# 			continue
	# 		var new_pos = enemy_pos + direction
	# 		if not _grid.is_ground(new_pos) or not _grid.is_within_bounds(new_pos):
	# 			continue
	# 		if player_pos.distance_to(new_pos) < player_pos.distance_to(enemy_pos + move_direction):
	# 			move_direction = direction
	#
	# 	if move_direction != Vector2i.ZERO:
	# 		await _grid.move(enemy, move_direction)
	#
	# 	## update position
	# 	enemy_pos = _grid.local_to_map(enemy.position)

	#### ATTACK
	# 	if player_pos in _grid.get_surrounding_cells(enemy_pos):
	# 		await VfxManager.spawn_effect(VfxManager.Effect.SLASH, _player.global_position)
	# 		Events.camera_shake.emit(0.8)
	# 		total_damage += enemy.attack_player()

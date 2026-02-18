class_name Enemy
extends Sprite2D

var last_movement := Vector2i.ZERO


# return damage
func attack_player() -> int:
	return 1

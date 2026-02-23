class_name Enemy
extends Sprite2D

var last_movement := Vector2i.ZERO
var stun := 0


# return damage
func attack_player() -> int:
	return 1

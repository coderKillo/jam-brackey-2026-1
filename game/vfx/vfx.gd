class_name Vfx
extends AnimatedSprite2D


func _ready():
	animation_finished.connect(func(): queue_free())

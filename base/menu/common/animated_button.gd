class_name AnimatedButton
extends Button

@export_group("animation")
@export_subgroup("scale")
@export var scale_normal := Vector2.ONE
@export var scale_up := Vector2(1.2, 1.2)
@export var scale_pressed := Vector2(0.6, 0.6)

@export_subgroup("rotation")
@export var rotation_normal := 0.0
@export var rotation_pressed := 0.1

@export_subgroup("time")
@export var time := 1.2

@onready var click_sound := $Click as AudioStreamPlayer
@onready var hover_sound := $Hover as AudioStreamPlayer


func _ready():
	$Content/Button.text = text


func _process(_delta):
	$Content.pivot_offset = size / 2.0


func _enter_tree():
	AnimationController.register_button(self)


func _exit_tree():
	pass

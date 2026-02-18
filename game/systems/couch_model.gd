class_name CouchModel
extends Node2D

const SLOT_SIZE = 16
const BORDER_SIZE = 4

@export var slot_count := 3

@export var left_texture: Texture
@export var right_texture: Texture
@export var slot_texture: Texture
@export var border_texture: Texture


func _ready():
	setup(slot_count)


func setup(slots: int):
	for child in get_children():
		child.queue_free()

	var size = SLOT_SIZE + slots * SLOT_SIZE + (slots - 1) * BORDER_SIZE
	var pointer = -(size / 2.0)

	var left = Sprite2D.new()
	left.texture = left_texture
	left.position.x = pointer
	add_child(left)
	pointer += SLOT_SIZE

	for i in slots:
		var slot = Sprite2D.new()
		slot.texture = slot_texture
		slot.position.x = pointer
		add_child(slot)

		if i < (slots - 1):
			pointer += (SLOT_SIZE / 2.0 + BORDER_SIZE / 2.0)
			var border = Sprite2D.new()
			border.texture = border_texture
			border.position.x = pointer
			add_child(border)
			pointer += (SLOT_SIZE / 2.0 + BORDER_SIZE / 2.0)

	pointer += SLOT_SIZE
	var right = Sprite2D.new()
	right.texture = right_texture
	right.position.x = pointer
	add_child(right)

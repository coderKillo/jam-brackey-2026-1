class_name CouchModel
extends Node2D

const SLOT_SIZE = 16
const BORDER_SIZE = 4
const SELECTION_VALID = 0
const SELECTION_INVALID = 1

@export var left_texture: Texture
@export var right_texture: Texture
@export var slot_texture: Texture
@export var border_texture: Texture

@onready var selector: Sprite2D = $Selector

var _slot_position: Array[float]
var _selector_position := Vector2.ZERO


func _process(_delta):
	selector.position = lerp(selector.position, _selector_position, 0.2)


func setup(slots: int):
	for child in get_children():
		if child == selector:
			continue
		child.queue_free()
	_slot_position.clear()

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
		_slot_position.append(pointer)

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


func select(slot_index: int, valid: bool):
	selector.show()
	_selector_position.x = _slot_position[slot_index]
	_selector_position.y = 0

	if valid:
		selector.frame = SELECTION_VALID
	else:
		selector.frame = SELECTION_INVALID


func reset():
	selector.hide()

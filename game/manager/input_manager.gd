class_name InputManager
extends Node

enum InputType {
	NONE,
	DIRECTION,
	CELL,
	SLOT,
}

@export var target_grid: TargetGrid
@export var couch_model: CouchModel

signal input_received

var cell_position: Vector2i
var slot_index: int
var direction: Vector2i
var input_type: InputType

var _active: bool = false


func _ready():
	assert(target_grid)
	assert(couch_model)

	target_grid.cell_selected.connect(_on_cell_selected)
	couch_model.slot_selected.connect(_on_slot_selected)


func setup() -> void:
	reset()


func reset():
	direction = Vector2i.ZERO
	cell_position = Vector2i.ZERO
	slot_index = -1
	input_type = InputType.NONE


func active(value: bool):
	if value:
		reset()
	_active = value


func is_cell_selected() -> bool:
	return input_type == InputType.CELL


func get_cell_position() -> Vector2i:
	return cell_position


func is_slot_selected() -> bool:
	return input_type == InputType.SLOT


func get_slot() -> int:
	return slot_index


func is_direction_pressed() -> bool:
	return input_type == InputType.DIRECTION


func get_direction() -> Vector2i:
	return direction


func _process(_delta):
	if not _active:
		return

	direction = Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		direction = Vector2i.UP
	if Input.is_action_pressed("move_down"):
		direction = Vector2i.DOWN
	if Input.is_action_pressed("move_left"):
		direction = Vector2i.LEFT
	if Input.is_action_pressed("move_right"):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		_input_received(InputType.DIRECTION)


func _on_cell_selected(cell: Vector2i):
	cell_position = cell
	_input_received(InputType.CELL)


func _on_slot_selected(slot: int):
	slot_index = slot
	_input_received(InputType.SLOT)


func _input_received(type: InputType):
	_active = false
	input_type = type
	input_received.emit()

class_name CouchModel
extends Node2D

const SLOT_SIZE = 16
const BORDER_SIZE = 4
const SELECTION_VALID = 0
const SELECTION_INVALID = 1

@export var ability_manager: AbilityManager
@export var left_texture: Texture
@export var right_texture: Texture
@export var border_texture: Texture

@onready var selector: Sprite2D = $Selector
@onready var slot_model_scene: PackedScene = preload("res://game/systems/slot_model.tscn")

var _slots: Array[Sprite2D]
var _selector_position := Vector2.ZERO


func _ready():
	ability_manager.slot_index_changed.connect(_on_slot_index_changed)
	ability_manager.slots_changed.connect(_on_slots_changed)
	Events.slot_count_changed.connect(_on_slot_count_changed)
	GameManager.state_changed.connect(_on_game_state_changed)


func _process(_delta):
	selector.position = lerp(selector.position, _selector_position, 0.2)


func setup(slots: int):
	_clear_model()

	var size = SLOT_SIZE + slots * SLOT_SIZE + (slots - 1) * BORDER_SIZE
	var pointer = -(size / 2.0)

	_add_sprite(left_texture, pointer)
	pointer += SLOT_SIZE

	for i in slots:
		var slot = slot_model_scene.instantiate()
		slot.position.x = pointer
		add_child(slot)
		_slots.append(slot)

		if i < (slots - 1):
			pointer += (SLOT_SIZE / 2.0 + BORDER_SIZE / 2.0)
			_add_sprite(border_texture, pointer)
			pointer += (SLOT_SIZE / 2.0 + BORDER_SIZE / 2.0)

	pointer += SLOT_SIZE
	_add_sprite(right_texture, pointer)

	update_slots()


func update_slots():
	for index in ability_manager.slot_count:
		var slot := ability_manager._slots[index] as AbilityManager.Slot
		var ability := ability_manager.get_ability(index)
		if not is_instance_valid(slot):
			continue

		var cooldown_label := _slots[index].get_node("Label") as Label
		cooldown_label.text = str(slot.cooldown)
		cooldown_label.visible = slot.cooldown > 0

		var character_sprite := _slots[index].get_node("Character") as Sprite2D
		character_sprite.texture = ability.texture
		character_sprite.visible = slot.ability != AbilityManager.Ability.EMPTY
		character_sprite.modulate.a = 0.4 if slot.cooldown > 0 else 1.0


func select(slot_index: int, valid: bool):
	selector.show()
	_selector_position.x = _slots[slot_index].position.x
	_selector_position.y = 0

	if valid:
		selector.frame = SELECTION_VALID
	else:
		selector.frame = SELECTION_INVALID


func reset():
	selector.hide()


func _on_slots_changed():
	update_slots()


func _on_slot_count_changed(count: int):
	setup(count)


func _on_slot_index_changed(index: int):
	if index == -1:
		reset()
	else:
		if ability_manager.is_slot_valid(index) and ability_manager._slots[index].cooldown <= 0:
			select(index, true)
		else:
			select(index, false)


func _on_game_state_changed(_state: Global.GameState):
	pass


func _clear_model():
	for child in get_children():
		if child == selector:
			continue
		child.queue_free()
	_slots.clear()


func _add_sprite(texture: Texture, x_position: float) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position.x = x_position
	add_child(sprite)

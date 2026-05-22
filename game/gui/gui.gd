class_name Gui
extends Control

#@onready var label: RichTextLabel = $DebugText

@export var main: Main

@onready var _stage_label: Label = $StageLabel


func _ready():
	assert(main)
	Events.debug_text.connect(_on_debug_text_changed)


func _process(_delta):
	_update_stage_ui()


func _on_debug_text_changed(_text: String):
	pass
	#label.text += text + "\n"


func _update_stage_ui():
	_stage_label.text = "Stage: " + str(main.current_stage)

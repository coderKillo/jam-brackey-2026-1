class_name Gui
extends Control

@onready var label: RichTextLabel = $DebugText


func _ready():
	Events.debug_text.connect(_on_debug_text_changed)


func _on_debug_text_changed(text: String):
	label.text += text + "\n"

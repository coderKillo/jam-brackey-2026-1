extends Control

@export var minimal_button_size = Vector2(50, 50)


func _ready():
	for i in GameState.get_max_level_reached() + 1:
		var button = Button.new()
		button.custom_minimum_size = minimal_button_size
		button.text = "Level %s" % (i + 1)
		button.pressed.connect(_on_load_level.bind(i))

		%LevelContainer.add_child(button)


func _on_load_level(id: int):
	SceneManager.load_level(id)

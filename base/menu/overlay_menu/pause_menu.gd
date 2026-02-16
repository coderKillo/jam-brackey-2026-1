extends OverlaidMenu


func _ready():
	%MainMenu.pressed.connect(_on_main_menu_pressed)
	%Continue.pressed.connect(_on_continue_pressed)


func _on_main_menu_pressed():
	SceneManager.load_main_menu()
	close()


func _on_restart_pressed():
	SceneManager.reload_level()
	close()


func _on_continue_pressed():
	close()

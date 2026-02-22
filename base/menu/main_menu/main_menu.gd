extends Control

var sub_menu: Control


func _ready():
	%Back.visible = false

	%NewGame.pressed.connect(_on_new_game_pressed)
	%Options.pressed.connect(_on_option_pressed)
	%Quit.pressed.connect(_on_quit_pressed)
	%Back.pressed.connect(_on_back_pressed)

	$ConfimNewGame.confirmed.connect(_on_new_game_confirmed)

	$Version.text = GameState.get_version()

	if OS.has_feature("web"):
		%Quit.hide()


## Handler


func _on_option_pressed():
	_open_sub_menu($Option)


func _on_back_pressed():
	_close_sub_menu()


func _on_new_game_pressed():
	_on_new_game_confirmed()


func _on_new_game_confirmed():
	GameState.reset()
	SceneManager.load_game_scene()


func _on_quit_pressed():
	get_tree().quit()


## Helper


func _open_sub_menu(menu: Control) -> void:
	$Menu.hide()
	%Back.show()
	sub_menu = menu
	sub_menu.show()


func _close_sub_menu() -> void:
	sub_menu.hide()
	$Menu.show()
	%Back.hide()

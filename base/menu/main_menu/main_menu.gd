extends Control

var sub_menu: Control


func _ready():
	%Continue.visible = GameState.get_max_level_reached() > 0
	%LevelSelect.visible = GameState.get_max_level_reached() > 0
	%Back.visible = false

	%Continue.pressed.connect(_on_continue_pressed)
	%NewGame.pressed.connect(_on_new_game_pressed)
	%LevelSelect.pressed.connect(_on_level_select_pressed)
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


func _on_continue_pressed():
	SceneManager.load_level(GameState.get_current_level())


func _on_new_game_pressed():
	if GameState.get_max_level_reached() >= 0:
		$ConfimNewGame.popup_centered()
	else:
		_on_new_game_confirmed()


func _on_new_game_confirmed():
	GameState.reset()
	SceneManager.load_level(GameState.get_current_level())


func _on_level_select_pressed():
	_open_sub_menu($LevelSelect)


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

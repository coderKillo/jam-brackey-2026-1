extends Node


func _input(event):
	if event.is_action_pressed("take_screenshot") and OS.is_debug_build():
		take_screenshot()


func take_screenshot():
	var screenshot_path = (
		"res://doc/screenshots/screenshot_%s_%s.png"
		% [Time.get_date_string_from_system(), Time.get_time_string_from_system()]
	)
	var image = get_viewport().get_texture().get_image()
	image.save_png(screenshot_path)

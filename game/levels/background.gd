class_name Background
extends ColorRect


func set_star_speed(value: float):
	material.set_shader_parameter("base_scroll_speed", value)
	material.set_shader_parameter("additional_scroll_speed", value)

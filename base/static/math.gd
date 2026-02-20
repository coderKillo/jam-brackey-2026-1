class_name Math


static func vector2i_direction(from: Vector2i, to: Vector2i) -> Vector2i:
	Events.debug_text.emit("from: %s to: %s" % [from, to])
	var x = clamp(to.x - from.x, -1, 1)
	var y = clamp(to.y - from.y, -1, 1)
	return Vector2i(x, y)

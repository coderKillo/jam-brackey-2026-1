class_name Math


static func vector2i_direction(from: Vector2i, to: Vector2i) -> Vector2i:
	var x = clamp(to.x - from.x, -1, 1)
	var y = clamp(to.y - from.y, -1, 1)
	return Vector2i(x, y)


static func vector2i_distance(a: Vector2i, b: Vector2i) -> int:
	var diff = abs(a - b)
	var distance_to_cell = diff.x + diff.y
	return distance_to_cell


static func min_distance2(a: Vector2i, b: Vector2i, distance: int) -> bool:
	return vector2i_distance(a, b) >= distance


static func min_distance3(a: Vector2i, b: Vector2i, c: Vector2i, distance: int) -> bool:
	return vector2i_distance(a, b) >= distance and vector2i_distance(a, c) >= distance

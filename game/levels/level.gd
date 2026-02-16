extends Node2D


func _win():
	Events.level_won.emit()


func _lose():
	Events.level_lose.emit()

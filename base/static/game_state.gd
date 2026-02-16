class_name GameState
extends Node

const SAVE_STATE_PATH = "user://global_state.tres"
const NO_VERSION_NAME = "0.0.0"

static var current: GameData


static func _log_version() -> void:
	var current_version = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
	if current_version.is_empty():
		current_version = NO_VERSION_NAME
	current.version_opened = current_version


static func _load_current_state() -> void:
	if FileAccess.file_exists(SAVE_STATE_PATH):
		current = ResourceLoader.load(SAVE_STATE_PATH)
	if not current:
		current = GameData.new()


static func open() -> void:
	_load_current_state()
	_log_version()
	save()


static func save() -> void:
	if current is GameData:
		ResourceSaver.save(current, SAVE_STATE_PATH)


static func reset() -> void:
	if current is not GameData:
		return
	current = GameData.new()
	save()


static func get_level_data(key: int) -> LevelData:
	if key not in current.level_data:
		current.level_data[key] = LevelData.new()
	return current.level_data[key]


static func get_version() -> String:
	return current.version_opened


static func get_current_level() -> int:
	return current.current_level


static func get_max_level_reached() -> int:
	return current.max_level_reached


static func set_current_level(level_number: int) -> void:
	current.max_level_reached = max(level_number, current.max_level_reached)
	current.current_level = level_number
	save()


static func start_game() -> void:
	save()

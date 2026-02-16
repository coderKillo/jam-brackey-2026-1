class_name AppSettings
extends Node
## Interface to read/write general application settings through [Config].

const AUDIO_SECTION = &"AudioSettings"
const GAME_SECTION = &"GameSettings"
const APPLICATION_SECTION = &"ApplicationSettings"
const CUSTOM_SECTION = &"CustomSettings"

const MUTE_SETTING = &"Mute"
const MASTER_BUS_INDEX = 0
const SYSTEM_BUS_NAME_PREFIX = "_"

# Input
static var default_action_events: Dictionary
static var initial_bus_volumes: Array

# Audio


static func get_bus_volume(bus_index: int) -> float:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	var linear = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	linear /= initial_linear
	return linear


static func set_bus_volume(bus_index: int, linear: float) -> void:
	var initial_linear = 1.0
	if initial_bus_volumes.size() > bus_index:
		initial_linear = initial_bus_volumes[bus_index]
	linear *= initial_linear
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear))
	Config.set_config(AUDIO_SECTION, get_audio_bus_name(bus_index).to_pascal_case(), linear)


static func is_muted() -> bool:
	return AudioServer.is_bus_mute(MASTER_BUS_INDEX)


static func set_mute(mute_flag: bool) -> void:
	AudioServer.set_bus_mute(MASTER_BUS_INDEX, mute_flag)
	Config.set_config(AUDIO_SECTION, MUTE_SETTING, mute_flag)


static func get_audio_bus_name(bus_iter: int) -> String:
	return AudioServer.get_bus_name(bus_iter)


static func set_audio_from_config() -> void:
	for bus_iter in AudioServer.bus_count:
		var bus_key: String = get_audio_bus_name(bus_iter).to_pascal_case()
		var bus_volume: float = get_bus_volume(bus_iter)
		initial_bus_volumes.append(bus_volume)
		bus_volume = Config.get_config(AUDIO_SECTION, bus_key, bus_volume)
		if is_nan(bus_volume):
			bus_volume = 1.0
			Config.set_config(AUDIO_SECTION, bus_key, bus_volume)
		set_bus_volume(bus_iter, bus_volume)

	var mute_audio_flag: bool = is_muted()
	mute_audio_flag = Config.get_config(AUDIO_SECTION, MUTE_SETTING, mute_audio_flag)
	set_mute(mute_audio_flag)


# Video

# All


static func set_from_config() -> void:
	set_audio_from_config()


static func set_from_config_and_window(_window: Window) -> void:
	set_from_config()

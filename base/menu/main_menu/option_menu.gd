extends Control


func _ready():
	%MasterVolume.value = AppSettings.get_bus_volume(AudioServer.get_bus_index("Master"))
	%MusicVolume.value = AppSettings.get_bus_volume(AudioServer.get_bus_index("Music"))
	%SfxVolume.value = AppSettings.get_bus_volume(AudioServer.get_bus_index("SFX"))
	%Mute.button_pressed = AppSettings.is_muted()

	%MasterVolume.value_changed.connect(_on_bus_volume_changed.bind("Master"))
	%MusicVolume.value_changed.connect(_on_bus_volume_changed.bind("Music"))
	%SfxVolume.value_changed.connect(_on_bus_volume_changed.bind("SFX"))
	%Mute.toggled.connect(_on_mute_toggled)


func _on_bus_volume_changed(value: float, bus: String):
	AppSettings.set_bus_volume(AudioServer.get_bus_index(bus), value)


func _on_mute_toggled(toggled_on: bool):
	AppSettings.set_mute(toggled_on)

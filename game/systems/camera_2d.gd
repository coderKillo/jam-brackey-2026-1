extends Camera2D

@export var camera_max_offset = 100.0
@export var camera_shake_max_offset = 40.0
@export var camera_shake_max_roll = 10.0
@export var camera_shake_max_stress = 1.0
@export var camera_shake_min_stress = 0.0
@export var camera_shake_reduction = 2.5

@export_range(0.0, 1.0) var stress: float = 0.0


func _ready():
	Events.camera_shake.connect(_on_camera_shake)


func _process(_delta):
	_process_shake(0.0, _delta)


func _process_shake(angle, delta) -> void:
	var shake = pow(stress, 2.0)

	rotation_degrees = angle + (camera_shake_max_roll * shake * _get_noise(randi(), delta))
	offset.x = (camera_max_offset * shake * _get_noise(randi(), delta + 2.0))
	offset.y = (camera_max_offset * shake * _get_noise(randi(), delta + 2.0))

	stress -= (camera_shake_reduction / 100.0)
	stress = clamp(stress, camera_shake_min_stress, camera_shake_max_stress)


func _on_camera_shake(intensity: float):
	stress = clamp(intensity, camera_shake_min_stress, camera_shake_max_stress)


func _get_noise(noise_seed, time) -> float:
	var n := FastNoiseLite.new()

	n.seed = noise_seed
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX
	n.frequency = 2.0

	return n.get_noise_1d(time)

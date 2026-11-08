extends Camera3D

@export var max_offset: float = 0.01
@export var shake_per_note: float = 0.25
@export var shake_decay: float = 1.5
@export var shake_freq: float = 35.0

var shakieness := 0.0
var noise := FastNoiseLite.new()
var noise_time := 0.0

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 1.0
	Speaker.note_played.connect(_on_note_played)

func _on_note_played(_pitch: int, velocity: int) -> void:
	shakieness = minf(shakieness + shake_per_note * (velocity / 127.0), 1.0)

func _process(dt: float) -> void:
	shakieness = move_toward(shakieness, 0.0, shake_decay * dt)

	if shakieness <= 0.0:
		h_offset = 0.0
		v_offset = 0.0
		return

	noise_time += dt * shake_freq
	var shake_factor := shakieness * shakieness
	h_offset = noise.get_noise_2d(noise_time, 300.0) * max_offset * shake_factor
	v_offset = noise.get_noise_2d(noise_time, 400.0) * max_offset * shake_factor

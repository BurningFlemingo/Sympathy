#claude made this file, ran outa time ):
extends AudioStreamPlayer3D

@export var target_pitch: int = 60

var playback: AudioStreamGeneratorPlayback
var phase := 0.0
var freq := 440.0
var mix_rate := 44100.0
var last_amp := 0.0

# Each entry is one partial: index 0 = fundamental, 1 = 2nd harmonic, etc.
@export var partial_amps: PackedFloat32Array = [1.0, 0.3, 0.1]
# Optional: frequency ratio per partial. Leave empty for plain harmonics (1, 2, 3...).
# Non-integer ratios (e.g. 1.0, 2.76, 5.4) give bell/glass/metal character.
@export var partial_ratios: PackedFloat32Array = []
# How much the upper partials fade in with energy (0 = static timbre, 1 = fully energy-driven)
@export_range(0.0, 1.0) var brightness_follows_energy := 0.6
@export var attack_time := 0.15   # seconds to ease in
@export var release_time := 0.4   # seconds to ease out

var phases := PackedFloat64Array()
var norm := 1.0

var current_amp := 0.0

func _ready() -> void:
	freq = 440.0 * pow(2.0, (target_pitch - 69) / 12.0)
	_setup_tone()

	var gen := AudioStreamGenerator.new()
	gen.mix_rate = mix_rate
	gen.buffer_length = 0.05
	stream = gen
	play()
	playback = get_stream_playback()
	
func _setup_tone() -> void:
	phases.resize(partial_amps.size())
	phases.fill(0.0)
	var total := 0.0
	for a in partial_amps:
		total += absf(a)
	norm = 1.0 / maxf(total, 0.001)

func _fill_audio(target_amp: float, energy_01: float) -> void:
	var frames := playback.get_frames_available()
	if frames == 0:
		return

	var buf := PackedVector2Array()
	buf.resize(frames)

	var bright := lerpf(1.0, clampf(current_amp / 0.3, 0.0, 1.0), brightness_follows_energy)

	var attack_k := 1.0 - exp(-1.0 / (attack_time * mix_rate))
	var release_k := 1.0 - exp(-1.0 / (release_time * mix_rate))

	for i in frames:
		var k := attack_k if target_amp > current_amp else release_k
		current_amp += (target_amp - current_amp) * k

		var s := 0.0
		for p in partial_amps.size():
			var ratio := partial_ratios[p] if p < partial_ratios.size() else float(p + 1)
			var gain: float = partial_amps[p] * (1.0 if p == 0 else bright)
			s += sin(TAU * phases[p]) * gain
			phases[p] = fmod(phases[p] + freq * ratio / mix_rate, 1.0)
		s *= current_amp * norm
		buf[i] = Vector2(s, s)

	playback.push_buffer(buf)
	
func set_pitch(pitch: int) -> void:
	target_pitch = pitch
	freq = 440.0 * pow(2.0, (pitch - 69) / 12.0)

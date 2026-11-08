extends Node3D
class_name SympatheticObject

@export_range(0, 11) var pitch_class: int = 0
@export_range(0, 8) var octave: int = 5
@export var held_decay: float = 0.25
@export var dampened_decay: float = 2.5
@export var sympathetic_resonance_factor = 0.1
@export var max_sympathetic_energy = 0.5
@export var indirect_energy_factor: float = 1.0
@export var max_indirect_energy: float = 0.3

@onready var light_state = get_node("/root/House/LightState")

var target_pitch: int = 0

const RESONANCE := {
	0: 1.0, 12: 0.5, -12: 0.6,
	19: 0.33, -19: 0.4,
	24: 0.25, -24: 0.3,
	7: 0.17, -7: 0.2,
	28: 0.2, 31: 0.17,
}

# {pitch, {held, energy}}
var energy_sources := {}

var energy: float = 0.0

signal note_hit(instance: SympatheticObject)
	
func _process(dt: float) -> void:
	var direct_energy: float = 0.0

	for pitch in energy_sources.keys():
		var source = energy_sources[pitch]
		var decay: float = 0.0
		if light_state.is_on and not source.held:
			decay = dampened_decay
		else:
			decay = held_decay
			
		source.energy *= exp(-decay * dt)
		if source.energy < 0.001:
			energy_sources.erase(pitch)
			continue
		direct_energy += source.energy

	energy = minf(direct_energy + _calc_indirect_energy(), 1.0)

func _on_speaker_note_played(pitch: int, velocity: int) -> void:
	if light_state.is_on:
		if note_matches(pitch):
			note_hit.emit(self)
		return

	var interval := target_pitch - pitch
	if RESONANCE.has(interval):
		var resonance: float = RESONANCE[interval] * (velocity / 127.0)
		resonance = resonance * sympathetic_resonance_factor
		if interval != 0:
			resonance = minf(resonance, max_sympathetic_energy)
			if energy_sources.has(pitch):
				resonance = maxf(resonance, energy_sources[pitch].energy)
		energy_sources[pitch] = { "energy": resonance, "held": true }
		
func _on_speaker_note_released(pitch: int) -> void:
	if energy_sources.has(pitch):
		energy_sources[pitch].held = false
		
func note_matches(pitch: int) -> bool:
	return pitch == target_pitch

func _on_hit(_velocity: int) -> void:
	print("hit!")
	
func _on_resonate(_resonance: float) -> void:
	print("resonated")
	
func _calc_indirect_energy() -> float:
	var sum: float = 0.0
	for other: SympatheticObject in get_tree().get_nodes_in_group("Sympathetic"):
		if other == self:
			continue
		var interval := target_pitch - other.target_pitch
		if RESONANCE.has(interval):
			sum += other.energy * RESONANCE[interval] * indirect_energy_factor
	return minf(sum, max_indirect_energy)
	
func set_active(active: bool) -> void:
	if active == true:
		Speaker.note_played.connect(_on_speaker_note_played)
		Speaker.note_released.connect(_on_speaker_note_released)
		target_pitch = octave * 12 + pitch_class
		add_to_group("Sympathetic")
	else: 
		remove_from_group("Sympathetic")
		Speaker.note_played.disconnect(_on_speaker_note_played)
		Speaker.note_released.disconnect(_on_speaker_note_released)
		energy_sources.clear()

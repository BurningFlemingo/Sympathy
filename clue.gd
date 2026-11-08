extends Node3D

@export var chord_window_ms = 300
@export var is_active: bool = false
@export var level: int = 0

signal chord_struck

var targets: Array[SympatheticObject] = []
var last_hit_ms := {}

const sentinel_time: int = -9999

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(is_active)
	add_to_group("level_%d" % level)
	
func _on_target_hit(target: SympatheticObject) -> void:
	var current_time: int = Time.get_ticks_msec()
	last_hit_ms[target] =  current_time
	for last_hit_time in last_hit_ms.values():
		if current_time - last_hit_time > chord_window_ms:
			return
	chord_struck.emit()
	print("chord struck!")
	_reset()
		
func _on_speaker_note_played(pitch: int, _velocity: int) -> void:
	for target in targets:
		if target.note_matches(pitch):
			return
	_reset()
	
func _reset() -> void:
	for target in targets:
		last_hit_ms[target] = sentinel_time
	
func set_active(active: bool) -> void:
	if active == true:
		add_to_group("Clue")
		if not Speaker.note_played.is_connected(_on_speaker_note_played):
			Speaker.note_played.connect(_on_speaker_note_played)
		for child in get_children():
			if child is SympatheticObject:
				child.set_active(true)
				child.note_hit.connect(_on_target_hit)
				targets.append(child)
				last_hit_ms[child] = sentinel_time
	else:
		remove_from_group("Clue")
		if Speaker.note_played.is_connected(_on_speaker_note_played):
			Speaker.note_played.disconnect(_on_speaker_note_played)
		for child: SympatheticObject in targets:
			last_hit_ms[child] = sentinel_time
			child.set_active(false)
	
	is_active = false

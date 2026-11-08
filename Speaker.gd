extends Node

const NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
const KEY_TO_NOTE := {
	KEY_A: 60, KEY_W: 61, KEY_S: 62, KEY_E: 63, KEY_D: 64,
	KEY_F: 65, KEY_T: 66, KEY_G: 67, KEY_Y: 68, KEY_H: 69,
	KEY_U: 70, KEY_J: 71, KEY_K: 72,
}
const DAMPER_KEY := KEY_SPACE

signal note_played(pitch: int, velocity: int)
signal note_released(pitch: int)
signal damper_changed(value: int)

func _ready() -> void:
	OS.open_midi_inputs()
	print("Connected MIDI devices: ", OS.get_connected_midi_inputs())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMIDI:
		_handle_midi(event)
	elif(event is InputEventKey and not event.echo): 
		_handle_key(event)
				
func _handle_midi(event: InputEventMIDI) -> void:
	match event.message:
		MIDI_MESSAGE_NOTE_ON:
			if event.velocity > 0:
				note_played.emit(event.pitch, event.velocity)
			else:
				note_released.emit(event.pitch)
		MIDI_MESSAGE_NOTE_OFF:
			note_released.emit(event.pitch)
		MIDI_MESSAGE_CONTROL_CHANGE:
			const DAMPER_CONTROL_NUMBER := 64
			if event.controller_number == DAMPER_CONTROL_NUMBER:
				damper_changed.emit(event.controller_value)
				
func _handle_key(event: InputEventKey) -> void:
	var key := event.physical_keycode
	if key == DAMPER_KEY:
		if event.pressed:
			damper_changed.emit(127)
		else:
			damper_changed.emit(0)
	elif KEY_TO_NOTE.has(key):
		if event.pressed:
			note_played.emit(KEY_TO_NOTE[key], 100)
		else:
			note_released.emit(KEY_TO_NOTE[key])
			
func calc_octave(pitch: int) -> int:
	return pitch / 12 - 1
	
func calc_pitch_class(pitch: int) -> int:
	return pitch % 12
	
func note_name(pitch: int) -> String:
	var pitch_class: int = calc_pitch_class(pitch)
	var octave: int = calc_octave(pitch)
	var note: String = NOTE_NAMES[pitch_class]
	return "%s%d" % [note, octave]

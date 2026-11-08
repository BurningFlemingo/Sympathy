extends Node

var is_on: bool = true

signal turned_on()
signal turned_off()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Speaker.damper_changed.connect(_on_speaker_damper_changed)
	
func _on_speaker_damper_changed(value: int) -> void:
	var turn_on: bool = value < 60.0
	if is_on and not turn_on:
		turned_off.emit()
		$"./LightOff".play()
	elif not is_on and turn_on:
		turned_on.emit()
		$"./LightOn".play()
	is_on = turn_on

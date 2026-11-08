extends AudioStreamPlayer3D

@export var muffle_time = 0.4
@export var unmuffle_time = 0.8

var bus_id := AudioServer.get_bus_index("Ambience")
var lowpass := AudioServer.get_bus_effect(bus_id, 0) as AudioEffectLowPassFilter

func _ready() -> void:
	$/root/House/LightState.turned_on.connect(unmuffle)
	$/root/House/LightState.turned_off.connect(muffle)

func muffle() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(lowpass, "cutoff_hz", 500.0, muffle_time)

func unmuffle(amount_time := 0.4) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(lowpass, "cutoff_hz", 20000.0, unmuffle_time)

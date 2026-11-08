extends Node3D

@export var lights: Array[Light3D] = []
@export var shade_mat: StandardMaterial3D
@export var decay: float = 0.5

@onready var light_state = get_node("/root/House/LightState")

var is_on: bool = true

var on_light_energies: Array[float] = []
var on_emission_energy: float
var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for light in lights:
		on_light_energies.append(light.light_energy)
	on_emission_energy = shade_mat.emission_energy_multiplier
	light_state.turned_off.connect(_on_lights_turned_off)
	light_state.turned_on.connect(_on_lights_turned_on)
	
func _on_lights_turned_on() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	
	for i in lights.size():
		var light = lights[i]
		tween.tween_property(light, "light_energy", on_light_energies[i], decay)
	tween.tween_property(shade_mat, "emission_energy_multiplier", on_emission_energy, decay)
	
func _on_lights_turned_off() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	
	for i in lights.size():
		var light = lights[i]
		tween.tween_property(light, "light_energy", 0.0, 0.0)
	tween.tween_property(shade_mat, "emission_energy_multiplier", 0.0, decay / 3.0)

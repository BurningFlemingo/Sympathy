extends SympatheticObject

@export var glow_color := Color(0.327, 0.81, 0.785, 1.0)
@export var max_glow: float = 3.0
@export var max_shake_degrees: float = 2.0
@export_range(0.0, 1.0) var shake_roughness_factor: float = 0.2
@export var shake_x_freq: float = 55.0
@export var shake_z_freq: float = 43.0
@export var shake_phase_shift: float = 1.3

@onready var light: OmniLight3D = $OmniLight3D
@onready var pivot = $Pivot

var materials := []
var equilibrium_rotation: Vector3
var tween: Tween

func _on_hit(velocity: int) -> void:
	print("Object hit, Pitch Class = %d, Velocity - %d" % [self.pitch_class, velocity])
	
func _ready() -> void:
	equilibrium_rotation = pivot.rotation
	_setup_materials()
	light.light_color = glow_color
	
func _setup_materials() -> void:
	for mesh_instance: MeshInstance3D in pivot.find_children("*", "MeshInstance3D"):
		for i in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.get_active_material(i)
			if material is StandardMaterial3D:
				var new_material := material.duplicate()
				new_material.emission_enabled = true
				new_material.emission = glow_color
				new_material.emission_energy_multiplier = 0.0
				mesh_instance.set_surface_override_material(i, new_material)
				materials.append(new_material)

func _process(dt: float) -> void:
	super(dt)

	var glow_factor: float = self.energy * self.energy
	var light_strength: float = 1.0
	light.light_energy = glow_factor * light_strength
	
	if light_state.is_on:
		glow_factor = glow_factor / 10.0
	for material in materials:
		material.emission_energy_multiplier = glow_factor * max_glow
		
	var amp := clampf(self.energy, 0.0, 1.0)
	$Note._fill_audio(amp * 0.2, amp)
		
	#_shake(glow_factor)
	
func _shake(glow_factor: float) -> void:
	var time := Time.get_ticks_msec() / 1000.0
	var amplitude := deg_to_rad(max_shake_degrees) * glow_factor
	pivot.rotation = equilibrium_rotation + Vector3(
		sin(time * shake_x_freq) * amplitude,
		0.0,
		(sin(time * shake_z_freq + shake_phase_shift) + randf_range(-shake_roughness_factor, shake_roughness_factor)) * amplitude
	)

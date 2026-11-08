extends Node

@onready var transitions: AnimationPlayer = $LevelTransitions

var current_level: int = 0
var transitioning: bool = false

func _ready() -> void:
	for clue in get_tree().get_nodes_in_group("level_%d" % current_level):
		if not clue.chord_struck.is_connected(_on_chord_struck):
			clue.chord_struck.connect(_on_chord_struck)

func _on_chord_struck() -> void:
	if transitioning:
		return
		
	if not transitions.has_animation("level_%d_exit" % current_level):
		print("couldnt find exit animation")
		return
		
	transitioning = true
	get_tree().call_group("level_%d" % current_level, "set_active", false)

	var animation_name := "level_%d_exit" % current_level
	if transitions.has_animation(animation_name):
		print("transitioning level")
		transitions.play(animation_name)
		await transitions.animation_finished

	current_level += 1
	get_tree().call_group("level_%d" % current_level, "set_active", true)
	
	for clue in get_tree().get_nodes_in_group("level_%d" % current_level):
		if not clue.chord_struck.is_connected(_on_chord_struck):
			clue.chord_struck.connect(_on_chord_struck)
		
	transitioning = false

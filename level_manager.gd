extends Node

@onready var transitions: AnimationPlayer = $LevelTransitions

var current_level: int = 0
var transitioning: bool = false

func _ready() -> void:
	for clue in get_tree().get_nodes_in_group("level_%d" % current_level):
		if not clue.chord_struck.is_connected(_on_chord_struck):
			clue.chord_struck.connect(_on_chord_struck)

func _on_chord_struck() -> void:
	var obj_1: Node3D = get_node("/root/House/Level0/Object1")
	var obj_2: Node3D = get_node("/root/House/Level0/Object2")
	var obj_3: Node3D = get_node("/root/House/Level0/Object3")

	var tween: Tween = create_tween()
	tween.tween_property(obj_1, "position:x", 100.0, 2.0)
	tween.tween_property(obj_2, "position:x", 100.0, 2.0)
	tween.tween_property(obj_3, "position:x", 100.0, 2.0)
	
	$tada.play()
	
	await get_tree().create_timer(5.0).timeout
	
	$quack.play()
	

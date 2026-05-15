extends Node2D

@onready var left_door
@onready var right_door
var is_open: bool = false

func _ready():
	add_to_group("my_doors")
	left_door = get_node_or_null("Left")
	right_door = get_node_or_null("Right")

func open_door():
	if is_open: return
	is_open = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(left_door, "scale", Vector2(0.1, 1), 0.5)
	tween.tween_property(right_door, "scale", Vector2(0.1, 1), 0.5)

func close_door():
	if not is_open: return
	is_open = false
	var tween = create_tween().set_parallel(true)
	tween.tween_property(left_door, "scale", Vector2(1, 1), 0.5)
	tween.tween_property(right_door, "scale", Vector2(1, 1), 0.5)

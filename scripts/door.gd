extends Node2D

@export var open_duration: float = 0.5
@export var closed_scale: Vector2 = Vector2(1, 1)
@export var open_scale: Vector2 = Vector2(0.1, 1)

@onready var left_door = get_node("../../Door/Left")
@onready var right_door = get_node("../../Door/Right")

var is_open: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		toggle_door()

func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()

func open_door():
	if is_open: return
	is_open = true
	
	# Проверяем валидность узлов перед созданием Tween
	var tween = create_tween().set_parallel(true)
	tween.tween_property(left_door, "scale", open_scale, open_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(right_door, "scale", open_scale, open_duration).set_trans(Tween.TRANS_SINE)

func close_door():
	if not is_open: return
	is_open = false
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(left_door, "scale", closed_scale, open_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_property(right_door, "scale", closed_scale, open_duration).set_trans(Tween.TRANS_SINE)

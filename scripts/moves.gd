extends Node

@onready var camera = get_viewport().get_camera_2d()
var level1_view_pos = Vector2(-1080-64, -64)
var level2_view_pos = Vector2(-1080-64, -64+1920+64)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_body_entered_1(body: Node2D) -> void:
	move_camera(level1_view_pos)

func _on_body_entered_2(body: Node2D) -> void:
	move_camera(level2_view_pos)

func move_camera(target_pos):
	var tween = create_tween()
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

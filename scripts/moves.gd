extends Node2D

signal camera_move_requested(new_pos)

var level1_view_pos = Vector2(-1080-1080-64, -64)
var level2_view_pos = Vector2(-1080-1080-64, -64+1920+64)

func _on_body_entered_1(body: Node2D) -> void:
	camera_move_requested.emit(level1_view_pos)

func _on_body_entered_2(body: Node2D) -> void:
	camera_move_requested.emit(level2_view_pos)

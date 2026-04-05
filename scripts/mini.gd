extends Node2D

@export var small_val: float = 0.5
@export var big_val: float = 1.0

var is_shrinking: bool = true
var inside = false

func _on_entry_big_body_entered(body):
	if body.has_method("change_ball_size"):
		is_shrinking = true
func _on_entry_big_body_exited(body: Node2D) -> void:
	if not inside:
		body.change_ball_size(big_val)
		is_shrinking = false

func _on_entry_small_body_entered(body):
	if body.has_method("change_ball_size"):
		is_shrinking = false

func _on_center_zone_body_entered(body: Node2D) -> void:
	if body.has_method("change_ball_size"):
		inside = true
		var target = small_val if is_shrinking else big_val
		body.change_ball_size(target)

func _on_center_zone_body_exited(body: Node2D) -> void:
	if body.has_method("change_ball_size"):
		inside = false

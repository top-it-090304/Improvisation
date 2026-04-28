extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		get_tree().call_group("my_doors", "open_door")

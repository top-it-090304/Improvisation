extends Area2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _finish(body: Node2D) -> void:
	if body.name == "Ball": 
		print("Победа!")
		get_tree().reload_current_scene()
		# get_tree().quit()
		# get_tree().change_scene_to_file("res://Level2.tscn")

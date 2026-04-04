extends StaticBody2D

@export var rotation_speed: float = 1.5

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta

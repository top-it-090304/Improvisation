extends Area2D

@export var magnet_strength: float = 1000.0
@export var max_distance: float = 300.0

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody2D:
			apply_magnet_force(body)

func apply_magnet_force(body: RigidBody2D):
	var direction = global_position - body.global_position
	var distance = direction.length()
	
	if distance > 0:
		var force_dir = direction.normalized()
		var force_magnitude = (1.0 - (distance / max_distance)) * magnet_strength
		body.apply_central_force(force_dir * force_magnitude)

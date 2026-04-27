extends Area2D

@export var magnet_strength: float = 1000.0 # Сила притяжения
@export var max_distance: float = 300.0    # Максимальное расстояние действия

func _physics_process(delta: float) -> void:
	# Получаем все тела, которые находятся внутри зоны Area2D
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		# Проверяем, что это RigidBody2D (наш шарик)
		if body is RigidBody2D:
			apply_magnet_force(body)

func apply_magnet_force(body: RigidBody2D):
	# Направление от шарика к магниту
	var direction = global_position - body.global_position
	var distance = direction.length()
	
	if distance > 0:
		# Нормализуем направление (делаем длину вектора равной 1)
		var force_dir = direction.normalized()
		
		# Рассчитываем силу: чем ближе, тем мощнее (обратная квадратичная зависимость)
		# Либо просто линейно:
		var force_magnitude = (1.0 - (distance / max_distance)) * magnet_strength
		
		# Применяем силу к шарику
		body.apply_central_force(force_dir * force_magnitude)

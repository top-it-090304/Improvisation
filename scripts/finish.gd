extends Area2D

var ball_position : Vector2

func _ready() -> void:
	var ball = get_parent().get_node_or_null("Ball")
	ball_position = ball.global_position

func _finish(body: Node2D) -> void:
	if body.name == "Ball":
		
		print("Победа!")
		
		# Отключение активности
		if "is_active" in body:
			body.is_active = false
		
		# Сброс позиции
		var body_rid = body.get_rid()
		PhysicsServer2D.body_set_state(
			body_rid, 
			PhysicsServer2D.BODY_STATE_TRANSFORM, 
			Transform2D(0, ball_position)
		)
		
		# Остановка
		PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0)
		
		# Следующий уровень
		get_tree().current_scene.get_node_or_null("Levels").next_level()

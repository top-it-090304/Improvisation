extends Area2D

@onready var camera = get_viewport().get_camera_2d()
var level1_view_pos = Vector2(-1080-64, -64)

# Настройки лазера
@export var shock_duration: float = 0.4     # Длительность удара током
@export var respawn_height_offset: float = 200.0 
@export var fall_duration: float = 0.5

# Ссылки
var ball: RigidBody2D = null
var ball_start_scale: Vector2 = Vector2.ONE
var start_position: Vector2 = Vector2.ZERO
var is_teleporting: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	call_deferred("_capture_initial_ball_pos")

func _capture_initial_ball_pos():
	var ball_node = get_tree().current_scene.find_child("Ball", true, false)
	if ball_node:
		start_position = ball_node.global_position
	else:
		start_position = global_position

func _on_body_entered(body: Node2D) -> void:
	if is_teleporting:
		return
		
	if body.name == "Ball" and body is RigidBody2D:
		ball = body
		ball_start_scale = ball.scale
		print("Удар лазером!")
		
		var levels_manager = get_tree().root.find_child("Main", true, false)
		if levels_manager:
			Data.set_result(levels_manager.current_level_index, false)
			
		call_deferred("start_shock_teleport")

func start_shock_teleport():
	if not ball or is_teleporting:
		return
	
	is_teleporting = true
	
	if "is_active" in ball:
		ball.is_active = false
	
	ball.set_deferred("freeze", true)
	ball.linear_velocity = Vector2.ZERO
	ball.set_deferred("collision_layer", 0)
	ball.set_deferred("collision_mask", 0)
	
	animate_shock_effect()
	move_camera(level1_view_pos)

func animate_shock_effect():
	var tween = create_tween()
	
	tween.set_parallel(true)
	
	for i in range(5):
		var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(ball, "global_position", ball.global_position + shake_offset, 0.05)
	
	# Вспышка: делаем шарик ярко-белым (через modulate)
	tween.tween_property(ball, "modulate", Color(10, 10, 10, 1), 0.1) # Сильное свечение
	tween.tween_property(ball, "scale", ball_start_scale * 1.2, 0.1) # Слегка раздувается
	
	# 2. Исчезновение
	tween.set_parallel(false)
	tween.tween_property(ball, "modulate:a", 0.0, 0.1)
	tween.tween_property(ball, "scale", Vector2.ZERO, 0.1)
	
	tween.tween_interval(0.2)
	
	var respawn_pos = start_position + Vector2(0, -respawn_height_offset)
	
	tween.tween_callback(func():
		ball.global_position = respawn_pos
		ball.modulate = Color.WHITE
		ball.modulate.a = 0.0
		ball.scale = ball_start_scale
	)
	
	# 4. Появление сверху
	tween.set_parallel(true)
	tween.tween_property(ball, "global_position", start_position, fall_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(ball, "modulate:a", 1.0, fall_duration * 0.5)
	
	tween.set_parallel(false)
	tween.tween_callback(func(): finish_teleport())

func finish_teleport():
	if ball:
		ball.set_deferred("collision_layer", 1)
		ball.set_deferred("collision_mask", 1)
		ball.set_deferred("freeze", false)
		
		await get_tree().create_timer(0.1).timeout
		if "is_active" in ball:
			ball.is_active = true
		
		ball = null
		is_teleporting = false

func move_camera(target_pos):
	var tween = create_tween()
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

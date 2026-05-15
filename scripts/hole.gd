extends Area2D

@onready var camera = get_viewport().get_camera_2d()
var level1_view_pos = Vector2(-1080-64, -64)

@export var fall_duration: float = 0.8      # Длительность падения
@export var sink_depth: float = 30.0        # Глубина "проваливания" в дыру
@export var respawn_height_offset: float = 200.0  # Высота над начальной точкой
@export var manual_start_position: Vector2 = Vector2.ZERO  # Ручная настройка позиции

var ball: RigidBody2D = null
var ball_start_scale: Vector2 = Vector2.ONE
var start_position: Vector2 = Vector2.ZERO  # Начальная позиция шара
var is_teleporting: bool = false  # Флаг, чтобы избежать повторных срабатываний

# Визуальные узлы
var sprite: Sprite2D = null
var collision_shape: CollisionShape2D = null

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
		print("Шар коснулся дыры! Телепортирую на: ", start_position)
		get_tree().call_group("my_doors", "close_door")
		var levels_manager = get_tree().root.find_child("Main", true, false)
		Data.set_result(levels_manager.current_level_index, false)
		call_deferred("start_teleport")

func start_teleport():
	if not ball or is_teleporting:
		return
	
	is_teleporting = true
	
	if "is_active" in ball:
		ball.is_active = false
	
	ball.set_deferred("freeze", true)
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0
	
	ball.set_deferred("collision_layer", 0)
	ball.set_deferred("collision_mask", 0)
	
	animate_fall_into_hole()
	ball._apply_size_change(1.0)
	move_camera(level1_view_pos)
	

func animate_fall_into_hole():
	var tween = create_tween()
	tween.set_parallel(true)
	
	var sink_pos = global_position + Vector2(0, sink_depth)
	tween.tween_property(ball, "global_position", sink_pos, 0.3)
	tween.tween_property(ball, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(ball, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_interval(0.3)
	
	if start_position == Vector2.ZERO:
		start_position = global_position + Vector2(0, -200)
		print("ВНИМАНИЕ: Стартовая позиция = 0, использую запасную!")
	
	var respawn_pos = start_position + Vector2(0, -respawn_height_offset)
	print("Телепортирую шар в: ", respawn_pos)
	
	tween.tween_callback(func(): 
		ball.global_position = respawn_pos
		ball.scale = ball_start_scale * 0.3  # Начинаем с маленького размера
		ball.modulate.a = 0.8
	)
	
	tween.set_parallel(true)
	tween.tween_property(ball, "global_position", start_position, fall_duration)
	tween.tween_property(ball, "scale", ball_start_scale, fall_duration)
	tween.tween_property(ball, "modulate:a", 1.0, fall_duration * 0.3)
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
		print("Телепортация завершена")

func move_camera(target_pos):
	var tween = create_tween()
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

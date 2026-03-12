extends Area2D

# Настройки телепортации
@export var fall_duration: float = 0.8      # Длительность падения
@export var sink_depth: float = 30.0        # Глубина "проваливания" в дыру
@export var respawn_height_offset: float = 200.0  # Высота над начальной точкой
@export var manual_start_position: Vector2 = Vector2.ZERO  # Ручная настройка позиции

# Ссылки
var ball: RigidBody2D = null
var ball_start_scale: Vector2 = Vector2.ONE
var start_position: Vector2 = Vector2.ZERO  # Начальная позиция шара
var is_teleporting: bool = false  # Флаг, чтобы избежать повторных срабатываний

# Визуальные узлы
var sprite: Sprite2D = null
var collision_shape: CollisionShape2D = null

func _ready() -> void:
	# Подключаем сигнал столкновения [cite: 6]
	body_entered.connect(_on_body_entered)
	
	# Используем call_deferred, чтобы сцена успела загрузиться, 
	# и мы могли найти положение шара
	call_deferred("_capture_initial_ball_pos")

func _capture_initial_ball_pos():
	# Ищем узел с именем "Ball" [cite: 4, 14]
	var ball_node = get_tree().current_scene.find_child("Ball", true, false)
	
	if ball_node:
		# Запоминаем его координаты как исходные
		start_position = ball_node.global_position
		print("Исходная позиция шара сохранена: ", start_position)
	else:
		# Если шар не найден, используем текущую позицию лузы как страховку 
		start_position = global_position
		print("Предупреждение: Шар не найден, установлена позиция лузы")

func _on_body_entered(body: Node2D) -> void:
	# Если уже телепортируемся - игнорируем
	if is_teleporting:
		return
		
	if body.name == "Ball" and body is RigidBody2D:
		ball = body
		ball_start_scale = ball.scale
		print("Шар коснулся дыры! Телепортирую на: ", start_position)
		# Используем call_deferred для безопасного запуска
		call_deferred("start_teleport")

func start_teleport():
	if not ball or is_teleporting:
		return
	
	is_teleporting = true
	
	# Отключаем управление шаром
	if "is_active" in ball:
		ball.is_active = false
	
	# Замораживаем физику шара
	ball.set_deferred("freeze", true)
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0
	
	# Отключаем коллизию, чтобы шар не взаимодействовал с миром
	ball.set_deferred("collision_layer", 0)
	ball.set_deferred("collision_mask", 0)
	
	# Запускаем анимацию
	animate_fall_into_hole()

func animate_fall_into_hole():
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. Шар "проваливается" в дыру (сжимается и опускается)
	var sink_pos = global_position + Vector2(0, sink_depth)
	tween.tween_property(ball, "global_position", sink_pos, 0.3)
	tween.tween_property(ball, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(ball, "modulate:a", 0.0, 0.3)
	
	# Ждем, пока шар "исчезнет"
	tween.set_parallel(false)
	tween.tween_interval(0.3)
	
	# Проверяем, что стартовая позиция задана
	if start_position == Vector2.ZERO:
		start_position = global_position + Vector2(0, -200)
		print("ВНИМАНИЕ: Стартовая позиция = 0, использую запасную!")
	
	# 2. Мгновенно перемещаем шар высоко над стартовой позицией
	var respawn_pos = start_position + Vector2(0, -respawn_height_offset)
	print("Телепортирую шар в: ", respawn_pos)
	
	tween.tween_callback(func(): 
		ball.global_position = respawn_pos
		ball.scale = ball_start_scale * 0.3  # Начинаем с маленького размера
		ball.modulate.a = 0.8
	)
	
	# 3. Анимация падения на стартовую позицию
	tween.set_parallel(true)
	
	# Падение вниз
	tween.tween_property(ball, "global_position", start_position, fall_duration)
	
	# Увеличение размера до нормального (как будто приближается)
	tween.tween_property(ball, "scale", ball_start_scale, fall_duration)
	
	# Появление (становится видимым)
	tween.tween_property(ball, "modulate:a", 1.0, fall_duration * 0.3)
	
	# 4. Завершение
	tween.set_parallel(false)
	tween.tween_callback(func(): finish_teleport())

func finish_teleport():
	if ball:
		# Включаем коллизию обратно
		ball.set_deferred("collision_layer", 1)  # Или ваш слой коллизии
		ball.set_deferred("collision_mask", 1)   # Или ваша маска коллизии
		
		# Размораживаем физику
		ball.set_deferred("freeze", false)
		
		# Возвращаем управление через небольшую задержку
		await get_tree().create_timer(0.1).timeout
		
		if "is_active" in ball:
			ball.is_active = true
		
		ball = null
		is_teleporting = false
		print("Телепортация завершена")

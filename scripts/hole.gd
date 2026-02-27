extends Area2D

# Настройки телепортации
@export var fall_duration: float = 0.8      # Длительность падения
@export var sink_depth: float = 30.0        # Глубина "проваливания" в дыру
@export var respawn_height_offset: float = 200.0  # Высота над начальной точкой
@export var manual_start_position: Vector2 = Vector2.ZERO  # Ручная настройка позиции

# Визуальные настройки
@export var hole_radius: float = 35.0       # Радиус дыры
@export var hitbox_radius: float = 25.0  # Радиус хит-бокса (меньше визуального)
@export var hole_color: Color = Color(0.2, 0.15, 0.1, 0.9)  # Темно-коричневый
@export var rim_color: Color = Color(0.4, 0.25, 0.15, 1.0)  # Светло-коричневый
@export var show_debug_lines: bool = true   # Показывать линии отладки

# Ссылки
var ball: RigidBody2D = null
var ball_start_scale: Vector2 = Vector2.ONE
var start_position: Vector2 = Vector2.ZERO  # Начальная позиция шара
var is_teleporting: bool = false  # Флаг, чтобы избежать повторных срабатываний

# Визуальные узлы
var sprite: Sprite2D = null
var collision_shape: CollisionShape2D = null

func _ready() -> void:
	# Подключаем сигнал
	body_entered.connect(_on_body_entered)
	
	# Создаем визуальное представление
	_setup_visuals()
	
	# Пробуем найти стартовую позицию разными способами
	_find_start_position()

func _setup_visuals():
	# Создаем Sprite2D если его нет
	sprite = Sprite2D.new()
	sprite.name = "HoleSprite"
	add_child(sprite)
	
	# Устанавливаем Z-индекс - отрицательное значение, чтобы быть под шаром
	sprite.z_index = 0
	
	# Создаем простую текстуру дыры (черный круг)
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	
	# Рисуем круг вручную
	for x in range(64):
		for y in range(64):
			var dx = x - 32
			var dy = y - 32
			var dist = sqrt(dx*dx + dy*dy)
			if dist < 30:
				# Внутренняя часть дыры
				var alpha = 1.0
				if dist > 25:
					alpha = 1.0 - (dist - 25) / 5.0  # Плавное затухание краев
				image.set_pixel(x, y, Color(0.1, 0.1, 0.1, alpha))
			elif dist < 32:
				# Края дыры
				image.set_pixel(x, y, Color(0.3, 0.2, 0.1, 0.8))
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.centered = true
	sprite.scale = Vector2(hole_radius / 30.0, hole_radius / 30.0)
	
	# Создаем или находим CollisionShape2D
	collision_shape = get_node_or_null("CollisionShape2D")
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		add_child(collision_shape)
		
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = hitbox_radius  # Немного меньше визуального размера
		collision_shape.shape = circle_shape

func _find_start_position():
	# Если задана ручная позиция - используем её
	if manual_start_position != Vector2.ZERO:
		start_position = manual_start_position
		print("Использую ручную стартовую позицию: ", start_position)
		return
	
	# Способ 1: Ищем по имени в текущей сцене
	var start_point = get_tree().current_scene.find_child("StartPosition", true, false)
	if start_point:
		start_position = start_point.global_position
		print("Найдена StartPosition по имени: ", start_position)
		return
	
	# Способ 2: Ищем по группе
	var start_nodes = get_tree().get_nodes_in_group("start_position")
	if start_nodes.size() > 0:
		start_position = start_nodes[0].global_position
		print("Найдена StartPosition по группе: ", start_position)
		return
	
	# Если ничего не нашли, используем позицию дыры + смещение (как запасной вариант)
	start_position = global_position + Vector2(0, -200)
	print("Стартовая позиция не найдена! Использую запасную: ", start_position)

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

# Визуальная отладка в редакторе
func _draw() -> void:
	if Engine.is_editor_hint() or show_debug_lines:
		# Рисуем круг - дыру (в редакторе всегда, в игре только если включено)
		draw_circle(Vector2.ZERO, hole_radius, hole_color)
		draw_circle(Vector2.ZERO, hole_radius * 0.7, Color(0.1, 0.1, 0.1, 0.9))
		
		# Рисуем ободок дыры
		draw_arc(Vector2.ZERO, hole_radius, 0, 2*PI, 32, rim_color, 2)
		draw_arc(Vector2.ZERO, hole_radius * 0.9, 0, 2*PI, 32, Color(0.3, 0.2, 0.1), 1)
		
		# Рисуем стрелку вниз (в дыру)
		draw_line(Vector2(0, hole_radius * 0.3), Vector2(0, hole_radius * 0.7), rim_color, 2)
		draw_line(Vector2(-5, hole_radius * 0.6), Vector2(0, hole_radius * 0.7), rim_color, 2)
		draw_line(Vector2(5, hole_radius * 0.6), Vector2(0, hole_radius * 0.7), rim_color, 2)
		

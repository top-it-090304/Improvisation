extends Area2D

# Настройки пули
@export var speed: float = 500.0  # Скорость полета
@export var push_force: float = 800.0  # Сила отталкивания шара
@export var lifetime: float = 3.0  # Время жизни пули (сек)
@export var bullet_radius: float = 10.0  # Радиус пули
@export var bullet_color: Color = Color(1.0, 0.8, 0.2, 1.0)  # Цвет пули

# Ссылки
var direction: Vector2 = Vector2.RIGHT  # Направление полета
var shooter: Node2D = null  # Кто выстрелил

func _ready() -> void:
	# Подключаем сигналы
	z_index = 3 
	body_entered.connect(_on_body_entered)
	
	# Настраиваем коллизию
	_setup_collision()
	
	# Создаем визуальное представление
	_setup_visual()
	
	# Удаляем пулю через время
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _setup_collision():
	# Настраиваем слои коллизии
	collision_layer = 0  # Пуля не обнаруживается другими
	collision_mask = 1   # Обнаруживает слой 1 (стены и шар)

func _setup_visual():
	# Создаем простой спрайт для пули
	var sprite = Sprite2D.new()
	sprite.name = "BulletSprite"
	add_child(sprite)
	
	# Создаем текстуру (круг с градиентом)
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	
	var center = 16
	for x in range(32):
		for y in range(32):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx*dx + dy*dy)
			if dist < 14:
				# Ядро пули
				var alpha = 1.0
				if dist > 10:
					alpha = 1.0 - (dist - 10) / 4.0
				# Смешиваем с базовым цветом
				var color = bullet_color
				color.a = alpha
				image.set_pixel(x, y, color)
			elif dist < 16:
				# Свечение
				var glow_color = bullet_color
				glow_color.a = 0.3
				image.set_pixel(x, y, glow_color)
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.centered = true
	sprite.scale = Vector2(bullet_radius / 14.0, bullet_radius / 14.0)
	
	# Добавляем CollisionShape2D
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = bullet_radius
	collision_shape.shape = circle_shape
	add_child(collision_shape)
	
	# Поворачиваем пулю в направлении движения
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Движение пули
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Столкновение с шаром
	if body.name == "Ball" and body is RigidBody2D:
		# Применяем силу отталкивания
		var push_direction = direction.normalized()
		body.apply_central_impulse(push_direction * push_force)
		
		# Визуальный эффект
		create_hit_effect()
		
		# Удаляем пулю
		queue_free()
	
	# Столкновение со стеной (любой StaticBody2D или TileMap)
	elif body is StaticBody2D or body is TileMap or body is RigidBody2D:
		create_hit_effect()
		queue_free()

func create_hit_effect():
	# Эффект при попадании
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.05)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

extends Node2D

# Настройки стрельбы
@export var shoot_interval: float = 2.0  # Интервал между выстрелами (сек)
@export var bullet_speed: float = 500.0  # Скорость пули
@export var bullet_push_force: float = 800.0  # Сила отталкивания шара
@export var bullet_lifetime: float = 3.0  # Время жизни пули (сек)
@export var bullet_radius: float = 10.0  # Радиус пули
@export var bullet_color: Color = Color(1.0, 0.8, 0.2, 1.0)  # Цвет пули

# Настройки спавна
@export var spawn_distance: float = 50.0  # Дистанция от пушки, где появляется пуля

# Ссылки
@export var bullet_scene: PackedScene  # Сцена пули

# Состояние
var shooting: bool = false
var can_shoot: bool = true

func _ready() -> void:
	start_shooting()

func start_shooting():
	if shooting:
		return
	shooting = true
	
	while shooting and is_inside_tree():
		await get_tree().create_timer(shoot_interval).timeout
		if can_shoot:
			shoot()

func stop_shooting():
	shooting = false

func shoot():
	if not bullet_scene:
		print("Ошибка: не назначена сцена пули!")
		return
	
	# Создаем пулю
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	# Направление стрельбы = поворот узла (0° = вправо)
	var shoot_direction = Vector2.RIGHT.rotated(rotation)
	
	# Позиция спавна пули = позиция пушки + направление * дистанция
	var spawn_pos = shoot_direction * spawn_distance
	bullet.global_position = global_position + spawn_pos
	
	# Настраиваем параметры пули
	bullet.direction = shoot_direction
	bullet.speed = bullet_speed
	bullet.push_force = bullet_push_force
	bullet.lifetime = bullet_lifetime
	bullet.bullet_radius = bullet_radius
	bullet.bullet_color = bullet_color
	
	# Поворачиваем пулю в направлении полета
	bullet.rotation = shoot_direction.angle()

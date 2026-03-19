extends RigidBody2D

const G_SCALE = 1000.0 
const MAX_OFFSET = 200.0
const TILT_STRENGTH = 50.0 # Сила смещения фона (увеличили для видимости)

var is_active = false
var start_mouse_pos = Vector2.ZERO

var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	linear_damp = 0.5
	angular_damp = 0.5
	can_sleep = false 
	# Используем call_deferred, чтобы сцена полностью загрузилась перед поиском фона
	call_deferred("_init_background")

func _init_background():
	bg_node = get_tree().current_scene.find_child("Background", true, false)
	if bg_node:
		# Находим реальный центр экрана
		var screen_center = get_viewport_rect().size / 2
		# Ставим фон в центр и запоминаем это как базу
		bg_node.global_position = screen_center
		bg_start_pos = screen_center
		
		if bg_node is Sprite2D:
			bg_node.centered = true

func _physics_process(_delta: float) -> void:
	if not is_active:
		stop_ball()
		_update_bg_tilt(Vector2.ZERO)
		return

	var accel = Input.get_accelerometer()
	var target_force = Vector2.ZERO

	# Расчет силы (акселерометр или мышь)
	if accel.length() > 0.1:
		target_force = Vector2(accel.x, -accel.y) * G_SCALE
	else:
		var offset = get_global_mouse_position() - start_mouse_pos
		var strength = clamp(offset.length() / MAX_OFFSET, 0.0, 1.0)
		target_force = offset.normalized() * strength * (9.8 * G_SCALE)

	constant_force = target_force * mass
	
	# Обновляем наклон фона
	_update_bg_tilt(target_force)

func _update_bg_tilt(t_force: Vector2):
	if bg_node:
		# Нормализуем силу относительно гравитации, чтобы получить значение от 0 до 1
		var norm_force = t_force / (9.8 * G_SCALE)
		var tilt_offset = -norm_force * TILT_STRENGTH
		
		# Плавное движение к целевой точке (база + смещение)
		bg_node.global_position = bg_node.global_position.lerp(bg_start_pos + tilt_offset, 0.1)

func stop_ball():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	constant_force = Vector2.ZERO

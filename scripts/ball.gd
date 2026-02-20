extends RigidBody2D

# Коэффициент масштаба
const G_SCALE = 1000.0 
const MAX_OFFSET = 200.0

var is_active = false
var start_mouse_pos = Vector2.ZERO

# Переменные для фона
var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	linear_damp = 0.5
	angular_damp = 0.5
	can_sleep = false 
	
	# Ищем фон и запоминаем его положение один раз при старте
	# Используем call_deferred, чтобы сцена успела полностью загрузиться
	call_deferred("_init_background")

func _init_background():
	bg_node = get_tree().current_scene.find_child("Background", true, false)
	if bg_node:
		bg_start_pos = bg_node.position

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_active = !is_active
			if is_active:
				start_mouse_pos = get_global_mouse_position()
			else:
				stop_ball()

func stop_ball():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	constant_force = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not is_active:
		stop_ball()
		# Возвращаем фон в центр, когда неактивны
		_update_bg_tilt(Vector2.ZERO)
		return

	var accel = Input.get_accelerometer()
	var target_force = Vector2.ZERO

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
		# Увеличил до 30.0, так как 1.0 слишком мало — ты не увидишь эффекта
		var max_shift = 30.0 
		var tilt_offset = -(t_force / (9.8 * G_SCALE)) * max_shift
		
		# Двигаем ОТНОСИТЕЛЬНО стартовой позиции
		bg_node.position = bg_node.position.lerp(bg_start_pos + tilt_offset, 0.1)

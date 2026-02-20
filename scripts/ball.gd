extends RigidBody2D

# Коэффициент масштаба: 1000 означает, что при полном наклоне (9.8) 
# ускорение будет 9800 пикселей/с². Настройте под размер своего поля.
const G_SCALE = 1000.0 
const MAX_OFFSET = 200.0

var is_active = false
var start_mouse_pos = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	# Трение для реалистичной остановки на ровной поверхности
	linear_damp = 0.5
	angular_damp = 0.5
	# Позволяет шарику быстрее реагировать на изменения
	can_sleep = false 

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_active = !is_active
			if is_active:
				start_mouse_pos = get_global_mouse_position()
			else:
				# Мгновенная остановка при выключении
				stop_ball()

func stop_ball():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	constant_force = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not is_active:
		stop_ball() # Гарантируем неподвижность, если не активен
		return

	var accel = Input.get_accelerometer()
	var target_force = Vector2.ZERO

	# 1. МОБИЛЬНЫЕ (Акселерометр)
	if accel.length() > 0.1:
		# Прямое использование значений: g=9.8 превращается в силу 9800
		target_force = Vector2(accel.x, -accel.y) * G_SCALE
	
	# 2. ПК (Эмуляция мышью)
	else:
		var offset = get_global_mouse_position() - start_mouse_pos
		var strength = clamp(offset.length() / MAX_OFFSET, 0.0, 1.0)
		# Симулируем наклон: чем дальше мышь, тем ближе к 9.8g
		target_force = offset.normalized() * strength * (9.8 * G_SCALE)

	# Применяем силу (F = m * a). Масса RigidBody2D по умолчанию 1.0
	constant_force = target_force * mass

extends RigidBody2D

# --- ФИЗИЧЕСКИЕ КОНСТАНТЫ ---
const GRAVITY_CONSTANT = 980.0  # Стандартная гравитация Godot
const MAX_OFFSET = 200.0        # Расстояние мыши для "максимального наклона"
const DEAD_ZONE = 10.0          # Мертвая зона

var is_active = false
var start_mouse_pos = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	# Linear Damp имитирует сопротивление воздуха/трение. 
	# 0.1 — почти вакуум, 1.0 — реальный мир, 2.0+ — вязкая среда.
	linear_damp = 1.0 
	
	# Убедимся, что масса влияет на расчеты (по умолчанию 1.0)
	mass = 1.0

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_active = !is_active
			if is_active:
				start_mouse_pos = get_global_mouse_position()
				linear_velocity = Vector2.ZERO 

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not is_active:
		return

	var accel = Input.get_accelerometer()
	var force_vector = Vector2.ZERO

	# 1. АКСЕЛЕРОМЕТР (естественная гравитация)
	if accel.length() > 0.1:
		# Акселерометр на мобилках выдает значения ~9.8 при полном наклоне.
		# Умножаем на 100, чтобы привести к экранным единицам Godot (~980).
		force_vector = Vector2(accel.x, -accel.y) * 100.0
	
	# 2. МЫШЬ (распределенная чувствительность)
	else:
		var current_mouse_pos = get_global_mouse_position()
		var offset = current_mouse_pos - start_mouse_pos
		var distance = offset.length()

		if distance > DEAD_ZONE:
			# Нормализуем силу: от 0.0 до 1.0 в зависимости от удаления мыши
			var strength = clamp(distance / MAX_OFFSET, 0.0, 1.0)
			# Применяем силу свободного падения, масштабированную на силу наклона
			force_vector = offset.normalized() * (strength * GRAVITY_CONSTANT)
		else:
			# Плавная остановка в центре
			state.linear_velocity = state.linear_velocity.lerp(Vector2.ZERO, 0.1)

	# Применяем итоговую силу (F = m * a)
	# Так как масса = 1, сила численно равна ускорению
	apply_central_force(force_vector * mass)
	
	sleeping = false

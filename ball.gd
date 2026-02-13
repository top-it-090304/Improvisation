extends RigidBody2D

# Настройки для физического "ощущения"
const ACCEL_SENSITIVITY = 180.0  # Усиление наклона акселерометра
const MOUSE_ATTRACTION = 10.0   # Коэффициент "тяти" к мыши
const AIR_RESISTANCE = 0.5      # Сопротивление воздуха (Damping)

func _ready() -> void:
	gravity_scale = 0.0          # Вид сверху, гравитация не тянет вниз
	linear_damp = AIR_RESISTANCE # Постепенно гасит скорость, как трение
	
	# Настройка PhysicsMaterial для отскока
	if not physics_material_override:
		var mat = PhysicsMaterial.new()
		mat.bounce = 0.75        # Упругость металла
		mat.friction = 0.1       # Гладкий металл
		physics_material_override = mat

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var accel = Input.get_accelerometer()
	
	if accel.length() > 0.1:
		var force = Vector2(accel.x, -accel.y) * ACCEL_SENSITIVITY
		apply_central_force(force)
	else:
		var target_pos = get_global_mouse_position()
		var to_mouse = target_pos - global_position
		var distance = to_mouse.length()
		
		# Если мышь далеко — тянем шарик силой
		if distance > 5: 
			var mouse_force = to_mouse * MOUSE_ATTRACTION
			apply_central_force(mouse_force)
		else:
			# ЭТОТ БЛОК РЕШАЕТ ПРОБЛЕМУ:
			# Когда мы точно на мышке, мы плавно гасим остаточную скорость,
			# но оставляем объект "активным" для столкновений.
			state.linear_velocity = state.linear_velocity.lerp(Vector2.ZERO, 0.2)
			
			# Принудительно будим тело, чтобы оно реагировало на стены или другие объекты
			sleeping = false 

extends RigidBody2D

const G_SCALE = 1000.0 
const MAX_OFFSET = 200.0
const TILT_STRENGTH = 50.0

var is_active = false
var start_mouse_pos = Vector2.ZERO

var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	linear_damp = 0.5
	angular_damp = 0.5
	can_sleep = false 
	call_deferred("_init_background")

func _init_background():
	bg_node = get_tree().current_scene.find_child("Background", true, false)
	if bg_node:
		var screen_center = get_viewport_rect().size / 2
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
	
	if accel.length() > 0.1:
		target_force = Vector2(accel.x, -accel.y) * G_SCALE
	else:
		var offset = get_global_mouse_position() - start_mouse_pos
		var strength = clamp(offset.length() / MAX_OFFSET, 0.0, 1.0)
		target_force = offset.normalized() * strength * (9.8 * G_SCALE)
	
	constant_force = target_force * mass
	_update_bg_tilt(target_force)

func _update_bg_tilt(t_force: Vector2):
	if bg_node:
		var norm_force = t_force / (9.8 * G_SCALE)
		var tilt_offset = -norm_force * TILT_STRENGTH
		bg_node.global_position = bg_node.global_position.lerp(bg_start_pos + tilt_offset, 0.1)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider and collider.has_method("hit_by_ball"):
			var normal = state.get_contact_local_normal(i)
			collider.hit_by_ball(self, normal)

func stop_ball():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	constant_force = Vector2.ZERO

func change_ball_size(new_scale: float):
	# Выполняем изменения в безопасное для физики время
	call_deferred("_apply_size_change", new_scale)

func _apply_size_change(new_scale: float):
	self.scale = Vector2.ONE

	# 1. Меняем визуал (Убедись, что имя узла именно "Texture", как на твоих скриншотах)
	var sprite = get_node_or_null("Texture")
	if sprite:
		sprite.scale = Vector2(new_scale/10, new_scale/10)
	else:
		print("Ошибка: Узел 'Texture' не найден в шаре!")

	# 2. Меняем физическую форму (Убедись, что имя узла "Shape" и это CircleShape2D)
	var col_shape = get_node_or_null("Shape")
	if col_shape and col_shape.shape is CircleShape2D:
		# Мы меняем масштаб самого узла коллизии
		col_shape.scale = Vector2(new_scale, new_scale)
	else:
		print("Ошибка: Узел 'Shape' не найден или не является CircleShape2D!")
	
	# 3. Обновляем массу для твоих расчетов силы движения (target_force * mass)
	mass = new_scale
	
	print("Размер зафиксирован на: ", new_scale)

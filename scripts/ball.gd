extends RigidBody2D

const MAX_OFFSET = 200.0
const TILT_STRENGTH = 50.0
var G_SCALE = 1000

var is_active = true
var start_mouse_pos = Vector2.ZERO

var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

var joystick_center = Vector2.ZERO
var joystick_vector = Vector2.ZERO
var is_dragging = false

func _ready() -> void:
	if Data.slow:
		G_SCALE = 100
	else:
		G_SCALE = 1000
	gravity_scale = 0
	linear_damp = 0.5
	angular_damp = 0.5
	can_sleep = false
	_apply_size_change(1.0)

func _physics_process(_delta: float) -> void:
	if not is_active:
		stop_ball()
		_update_bg_tilt(Vector2.ZERO)
		return
		
	var target_force = Vector2.ZERO
	
	if Data.control_type == "accel":
		var accel = Input.get_accelerometer()
		if accel.length() > 0.1:
			target_force = Vector2(accel.x, -accel.y) * G_SCALE
	else:
		target_force = joystick_vector * (9.8 * G_SCALE)
	
	constant_force = target_force * mass
	_update_bg_tilt(target_force)
	
func _input(event: InputEvent) -> void:
	if not is_active or Data.control_type != "joystick":
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			joystick_center = event.position
		else:
			is_dragging = false
			joystick_vector = Vector2.ZERO
			
	if event is InputEventScreenDrag and is_dragging:
		var offset = event.position - joystick_center
		var strength = clamp(offset.length() / MAX_OFFSET, 0.0, 1.0)
		joystick_vector = offset.normalized() * strength

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
	call_deferred("_apply_size_change", new_scale)

func _apply_size_change(new_scale: float):
	self.scale = Vector2.ONE
	var sprite = get_node_or_null("Texture")
	if sprite:
		sprite.scale = Vector2(new_scale/10, new_scale/10)
	var col_shape = get_node_or_null("Shape")
	if col_shape and col_shape.shape is CircleShape2D:
		col_shape.scale = Vector2(new_scale, new_scale)
	mass = new_scale

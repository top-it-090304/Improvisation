extends CharacterBody2D

const ACCELERATION = 100
const MAX_SPEED = 60

func _physics_process(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if x_input != 0:
		velocity.x += x_input * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	
	if y_input != 0:
		velocity.y += y_input * ACCELERATION * delta
		velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	else:
		velocity.y = move_toward(velocity.y, 0, ACCELERATION * delta)

	move_and_slide()
#hello world

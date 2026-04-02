extends Area2D

@export var bump_force: float = 1200.0  # Сила отстрела
@export var stun_time: float = 0.2      # Время блокировки управления игрока

func _ready():
	# Подключаем сигнал, если не подключен в редакторе
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Ball" and body is RigidBody2D:
		# 1. Рассчитываем направление ОТ центра бампера к шару
		var push_direction = (body.global_position - global_position).normalized()
		
		# 2. Блокируем ввод игрока, чтобы он не "сопротивлялся" отскоку
		if "input_locked" in body:
			body.input_locked = true
			_unlock_ball(body)
		
		# 3. Обнуляем текущую скорость шара (опционально, для предсказуемости)
		# body.linear_velocity = Vector2.ZERO 
		
		# 4. Даем мощный импульс
		body.apply_central_impulse(push_direction * bump_force)
		
		# 5. Сочная анимация
		_play_bump_animation()

func _unlock_ball(ball):
	await get_tree().create_timer(stun_time).timeout
	if is_instance_valid(ball):
		ball.input_locked = false

func _play_bump_animation():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

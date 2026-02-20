extends Area2D

@export var bump_force: float = 800.0  # Сила выстрела (настраивается в инспекторе)
@export var sound_player: AudioStreamPlayer2D  # Опционально: звук

func _ready():
	# Подключаем сигнал столкновения с телом
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что это шар (RigidBody2D)
	if body is RigidBody2D:
		# Рассчитываем направление ОТ бампера
		var direction = (body.global_position - global_position).normalized()
		# Применяем импульс (мгновенный толчок)
		body.apply_central_impulse(direction * bump_force)

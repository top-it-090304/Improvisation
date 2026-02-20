extends Area2D

func _finish(body: Node2D) -> void:
	if body.name == "Ball":
		# Выключаем управление и физику
		if "is_active" in body:
			body.is_active = false
		if body is RigidBody2D:
			body.freeze = true 
		
		var tween = create_tween()
		tween.set_parallel(true)
		
		# 1. УМЕНЬШЕНИЕ: TRANS_CUBIC уберет эффект «подпрыгивания» (увеличения)
		tween.tween_property(body, "scale", Vector2.ZERO, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
		# 2. ДВИЖЕНИЕ: точно в центр лузы
		tween.tween_property(body, "global_position", global_position, 0.6).set_trans(Tween.TRANS_CUBIC)
		
		# 3. ЗАТЕМНЕНИЕ: шар становится прозрачным, как будто скрывается в тени лузы
		tween.tween_property(body, "modulate:a", 0.0, 0.6)
		
		# 4. ЗАВЕРШЕНИЕ
		tween.set_parallel(false)
		tween.tween_callback(func(): _on_animation_finished(body))
func _on_animation_finished(body):
	# Возвращаем размер шару для следующего уровня
	body.scale = Vector2.ONE
	
	# Вызываем менеджер уровней
	var levels_manager = get_tree().current_scene.find_child("Levels", true, false)
	if levels_manager:
		levels_manager.next_level()

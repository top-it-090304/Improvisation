extends Control

@onready var levels = get_node("Levels")

func _ready():
	var grid = $GridContainer # Убедись, что путь к сетке кнопок верный
	var buttons = grid.get_children()
	
	for i in range(buttons.size()):
		# Подключаем нажатие (если еще не подключено в редакторе)
		if not buttons[i].pressed.is_connected(_on_level_button_pressed):
			buttons[i].pressed.connect(_on_level_button_pressed.bind(i))
		if Data.level_colors.has(i):
			buttons[i].self_modulate = Data.level_colors[i]

func _on_level_button_pressed(index: int):
	self.hide()
	var levels_manager = get_tree().current_scene.find_child("Levels", true, false)
	if levels_manager:
		levels_manager.load_level(index)
		var ball = get_tree().current_scene.find_child("Ball", true, false)
		if ball:
			ball.is_active = true

func set_level_button_color(index: int, is_success: bool):
	var grid = $GridContainer
	if index >= 0 and index < grid.get_child_count():
		var button = grid.get_child(index)
		if is_success:
			button.modulate = Color.GREEN  # Зеленый при победе
		else:
			button.modulate = Color.RED    # Красный при поражении

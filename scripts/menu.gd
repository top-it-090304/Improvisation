extends Control

# Ссылка на твой главный узел, который умеет загружать уровни
@onready var levels = get_node("Levels") # Укажи путь к своему Node2D

func _ready():
	var buttons = $GridContainer.get_children()
	for i in range(buttons.size()):
		# Привязываем нажатие кнопки к функции, передавая индекс i
		buttons[i].pressed.connect(_on_level_button_pressed.bind(i))

func _on_level_button_pressed(index: int):
	self.hide()
	var levels_manager = get_tree().current_scene.find_child("Levels", true, false)
	if levels_manager:
		levels_manager.load_level(index)
		var ball = get_tree().current_scene.find_child("Ball", true, false)
		if ball:
			ball.is_active = true

extends Control

@onready var main = get_tree().root.find_child("Main", true, false)

func _ready():
	var grid = $GridContainer
	var buttons = grid.get_children()
	for i in range(buttons.size()):
		if not buttons[i].pressed.is_connected(_on_level_button_pressed):
			buttons[i].pressed.connect(_on_level_button_pressed.bind(i))
		if Data.level_colors.has(i):
			buttons[i].self_modulate = Data.level_colors[i]

func _on_level_button_pressed(index: int):
	if main:
		main.load_level(index)
		Data.set_result(index, false)
		var ball = get_tree().current_scene.find_child("Ball", true, false)
		if ball:
			ball.is_active = true

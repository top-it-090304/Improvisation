extends Control

@onready var main = get_tree().root.find_child("Main", true, false)
var default_color = Color.WHITE

func _ready():
	var buttons = $GridContainer.get_children()
	for i in range(buttons.size()):
		if Data.level_colors.size() == 0:
			default_color = buttons[i].self_modulate
		if not buttons[i].pressed.is_connected(_on_level_button_pressed):
			buttons[i].pressed.connect(_on_level_button_pressed.bind(i))
	update_buttons_color()

func update_buttons_color():
	var buttons = $GridContainer.get_children()
	for i in range(buttons.size()):
		if Data.level_colors.has(i):
			buttons[i].self_modulate = Data.level_colors[i]
		else:
			buttons[i].self_modulate = default_color

func _on_level_button_pressed(index: int):
	if main:
		Data.set_result(index, false)
		var ball = get_tree().current_scene.find_child("Ball", true, false)
		if ball:
			ball.is_active = true
		main.load_level(index)

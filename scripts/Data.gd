extends Node

const SAVE_PATH = "user://save_data.cfg"

var level_colors = {}
var slow = false
var control_type = "accel"

func _ready():
	load_game()

func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return
	level_colors = config.get_value("game", "level_colors", {})
	slow = config.get_value("settings", "slow", false)
	control_type = config.get_value("settings", "control_type", "accel")

func set_result(index: int, is_win: bool):
	if is_win:
		level_colors[index] = Color.GREEN
	save_game()

func set_slow_mode(value: bool):
	slow = value
	save_game()
	
func set_control_type(value: String):
	control_type = value
	save_game()
	
func reset():
	level_colors = {}
	save_game()

func save_game():
	var config = ConfigFile.new()
	config.set_value("game", "level_colors", level_colors)
	config.set_value("settings", "slow", slow)
	config.set_value("settings", "control_type", control_type)
	var err = config.save(SAVE_PATH)
	if err != OK:
		print("Ошибка сохранения:", err)

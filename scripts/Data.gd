extends Node

const SAVE_PATH = "user://save_data.cfg"

var level_colors = {}
var slow = false

func _ready():
	load_game()
func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		return
	level_colors = config.get_value("game", "level_colors", {})
	slow = config.get_value("settings", "slow", false)

func set_result(index: int, is_win: bool):
	#level_colors[index] = Color.GREEN if is_win else Color.RED
	if is_win:
		level_colors[index] = Color.GREEN
	save_game()

func set_slow_mode(value: bool):
	slow = value
	save_game()

func save_game():
	var config = ConfigFile.new()
	config.set_value("game", "level_colors", level_colors)
	config.set_value("settings", "slow", slow)
	var err = config.save(SAVE_PATH)
	if err != OK:
		print("Ошибка сохранения:", err)

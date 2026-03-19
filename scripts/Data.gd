extends Node

# Храним результаты уровней: {индекс: цвет}
var level_colors = {}

func set_result(index: int, is_win: bool):
	level_colors[index] = Color.GREEN if is_win else Color.RED

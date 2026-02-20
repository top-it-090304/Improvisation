extends Node2D

var levels = [
	"res://levels/1.tscn",
	"res://levels/2.tscn",
	"res://levels/3.tscn"
]

var current_level_index = 0
var current_level_node = null

func _ready():
	# Первый уровень
	load_level(current_level_index)

func load_level(index):
	if current_level_node != null:
		current_level_node.queue_free()
	var level_resource = load(levels[index])
	current_level_node = level_resource.instantiate()
	add_child(current_level_node)

func next_level():
	current_level_index += 1
	if current_level_index < levels.size():
		print("Следующий уровень")
		call_deferred("load_level", current_level_index)
	else:
		print("Уровни закончились")
		current_level_index = 0
		call_deferred("load_level", current_level_index)

extends Node2D

var levels = [
	"res://levels/1.tscn",
	"res://levels/2.tscn",
	"res://levels/3.tscn",
	"res://levels/4.tscn",
	"res://levels/5.tscn",
	"res://levels/6.tscn",
	"res://levels/7.tscn",
	"res://levels/8.tscn",
	"res://levels/9.tscn"
]

var current_level_index = -1
var current_level_node = null

var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

func _ready():
	load_level(current_level_index)
	
func _init_background():
	bg_node = get_tree().current_scene.find_child("Background", true, false)
	if bg_node:
		var screen_center = get_viewport_rect().size / 2
		bg_node.global_position = screen_center
		bg_start_pos = bg_node.global_position
		if bg_node is Sprite2D:
			bg_node.centered = true 

func load_level(index):
	var bg = get_tree().current_scene.find_child("Background", true, false)
	if bg:
		bg.global_position = get_viewport_rect().size / 2
	current_level_index = index 
	if current_level_node != null:
		current_level_node.queue_free()
	var level_resource
	if index != -1:
		level_resource = load(levels[index])
	else:
		level_resource = load("res://levels/menu.tscn")
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
		
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_level_index != -1:
			load_level(-1)

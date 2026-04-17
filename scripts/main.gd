extends Node2D

@onready var camera = $Camera2D
@onready var levels_manager = get_tree().root.find_child("Main", true, false)

var levels = [
	"res://levels/1.tscn",
	"res://levels/2.tscn",
	"res://levels/3.tscn",
	"res://levels/4.tscn",
	"res://levels/5.tscn",
	"res://levels/6.tscn",
	"res://levels/7.tscn",
	"res://levels/8.tscn",
	"res://levels/9.tscn",
	"res://levels/10.tscn"
]

var main_menu_pos = Vector2(-64, -64)
var settings_pos = Vector2(1080-64, -64)
var level_view_pos = Vector2(-1080-64, -64)

var current_level_index = -1
var current_level_node = null

var bg_node : Sprite2D = null
var bg_start_pos : Vector2 = Vector2.ZERO

func _ready():
	pass

func load_level(index):
	current_level_index = index
	if current_level_node != null:
		current_level_node.queue_free()
		
	var level_resource
	if index != -1:
		level_resource = load(levels[index])
		current_level_node = level_resource.instantiate()
		current_level_node.position = level_view_pos
		add_child(current_level_node)
		move_camera(level_view_pos)
	else:
		move_camera(main_menu_pos)
		level_resource = load("res://levels/menu.tscn")
	
func _on_settings_icon_pressed():
	move_camera(settings_pos)

func _on_back_icon_pressed():
	move_camera(main_menu_pos)
	
func _on_menu_icon_pressed() -> void:
	move_camera(main_menu_pos)
	levels_manager.load_level(-1)

func move_camera(target_pos):
	var tween = create_tween()
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

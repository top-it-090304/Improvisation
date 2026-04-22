extends Node2D

@onready var camera = $Camera2D
@onready var levels_manager = get_tree().root.find_child("Main", true, false)
@onready var menu = get_tree().root.find_child("Menu", true, false)
@onready var real_btn = get_tree().root.find_child("Real", true, false)
@onready var slow_btn = get_tree().root.find_child("Slow", true, false)

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
	"res://levels/10.tscn",
	"res://levels/11.tscn"
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
	menu._ready()
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
	
func _on_settings_icon_pressed():
	update_frames()
	move_camera(settings_pos)

func _on_back_icon_pressed():
	menu.update_buttons_color()
	move_camera(main_menu_pos)
	
func _on_menu_icon_pressed() -> void:
	menu.update_buttons_color()
	levels_manager.load_level(-1)
	
func _on_area_1_area_entered(body: Node2D) -> void:
	move_camera(level_view_pos)

func _on_area_2_area_entered(body: Node2D) -> void:
	move_camera(level_view_pos)

func move_camera(target_pos):
	var tween = create_tween()
	tween.tween_property(camera, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)


#settings
func _on_real_pressed() -> void:
	Data.set_slow_mode(false)
	update_frames()
	
func _on_slow_pressed() -> void:
	Data.set_slow_mode(true)
	update_frames()

func update_frames():
	var style_real = real_btn.get_theme_stylebox("normal").duplicate()
	var style_slow = slow_btn.get_theme_stylebox("normal").duplicate()
	
	if Data.slow:
		style_slow.border_width_left = 8
		style_slow.border_width_right = 8
		style_slow.border_width_top = 8
		style_slow.border_width_bottom = 8
		style_real.border_width_left = 0
		style_real.border_width_right = 0
		style_real.border_width_top = 0
		style_real.border_width_bottom = 0
	else:
		style_real.border_width_left = 8
		style_real.border_width_right = 8
		style_real.border_width_top = 8
		style_real.border_width_bottom = 8
		style_slow.border_width_left = 0
		style_slow.border_width_right = 0
		style_slow.border_width_top = 0
		style_slow.border_width_bottom = 0

	real_btn.add_theme_stylebox_override("normal", style_real)
	slow_btn.add_theme_stylebox_override("normal", style_slow)
	real_btn.add_theme_stylebox_override("hover", style_real)
	slow_btn.add_theme_stylebox_override("hover", style_slow)

func _on_reset_pressed() -> void:
	Data.reset()
	_on_back_icon_pressed()

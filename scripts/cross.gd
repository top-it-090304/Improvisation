extends Node2D

@onready var wall_top = $Walls/Top
@onready var wall_bottom = $Walls/Bottom
@onready var wall_left = $Walls/Left
@onready var wall_right = $Walls/Right

func _ready():
	pass

func _walls_change(direction):
	wall_top.collision_layer = 0
	wall_bottom.collision_layer = 0
	wall_left.collision_layer = 0
	wall_right.collision_layer = 0
	if direction:
		wall_left.collision_layer = 1
		wall_right.collision_layer = 1
	else:
		wall_top.collision_layer = 1
		wall_bottom.collision_layer = 1

func _on_top_body_entered(body: Node2D) -> void:
	_walls_change(true)
func _on_bottom_body_entered(body: Node2D) -> void:
	_walls_change(true)
func _on_left_body_entered(body: Node2D) -> void:
	_walls_change(false)
func _on_right_body_entered(body: Node2D) -> void:
	_walls_change(false)

var ball_z = 0
func _on_z_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		ball_z = body.z_index
		if wall_left.collision_layer == 1:
			body.z_index = 3
func _on_z_body_exited(body: Node2D) -> void:
	if body.name == "Ball":
		body.z_index = ball_z

extends Camera3D

var rotation_start
var position_start

func _ready():
	rotation_start = rotation_degrees.y
	position_start = position.x

func _physics_process(_delta):
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		rotation_degrees.y += Input.get_axis("move_left", "move_right") * 0.1
		position.x += Input.get_axis("move_left", "move_right") * 0.01
	position.x = clamp(position.x, position_start - 0.5, position_start + 0.5)
	rotation_degrees.y = clamp(rotation_degrees.y, rotation_start - 5, rotation_start + 5)

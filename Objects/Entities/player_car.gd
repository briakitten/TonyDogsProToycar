extends CharacterBody3D

@onready var toy_car = $CarMesh

#too many freaking variables! \0w0/
var speed: int = 50
var direction: Vector2 = Vector2(velocity.x, velocity.z)
var gravity: float = 0.5
var max_velocity: float = 0
var rotation_speed: int = 2
var starting_rotation: float
var starting_tilt: float
var starting_scale: float
var jump_force: int = 15
var jump_count: int = 0
var jump_ongoing: bool = false
var acceleration: float = 0
var pressing_move: bool = false
var moving_backwards: float = 0

func _ready():
	starting_rotation = toy_car.rotation_degrees.y
	starting_tilt = toy_car.rotation_degrees.x
	starting_scale = toy_car.scale.y
	
func _physics_process(_delta):
	if !is_on_floor():
		velocity.y -= gravity
		if velocity.y > max_velocity:
			velocity.y = max_velocity
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		rotation_degrees.y -= Input.get_axis("move_left", "move_right") * rotation_speed
		toy_car.rotation_degrees.y -= Input.get_axis("move_left", "move_right") * 0.1
		toy_car.rotation_degrees.y = clamp(toy_car.rotation_degrees.y,\
			starting_rotation - 15, starting_rotation + 15)
		toy_car.rotation_degrees.x -= Input.get_axis("move_left", "move_right")
		toy_car.rotation_degrees.x = clamp(toy_car.rotation_degrees.x,\
			starting_tilt - 7, starting_tilt + 7)
	else:
		toy_car.rotation_degrees.y = starting_rotation
		toy_car.rotation_degrees.x = starting_tilt

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_force
		jump_ongoing = true
	if Input.is_action_just_released("jump") or jump_count == 20:
		jump_ongoing = false
		jump_count = 0
	if jump_ongoing:
		velocity.y += jump_force
		jump_count += 1
	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_backwards"):
		if acceleration <= 0.3:
			acceleration += 0.01
		pressing_move = true
		if Input.is_action_pressed("move_backwards"):
			moving_backwards = 180
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backwards"):
		pressing_move = false
		if Input.is_action_just_released("move_backwards"):
			acceleration = 0
	if !pressing_move and acceleration > 0:
		acceleration -= 0.005
	if acceleration == 0:
		moving_backwards = 0
	position.z -= cos(deg_to_rad(rotation_degrees.y + moving_backwards)) * acceleration
	position.x -= sin(deg_to_rad(rotation_degrees.y + moving_backwards)) * acceleration
	velocity.z = 0
	velocity.x = 0
	move_and_slide()

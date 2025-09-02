extends CharacterBody3D

var speed: int = 50
var direction: Vector2 = Vector2(velocity.x, velocity.z)
var gravity = 0.5
var max_velocity = 0
var rotation_speed: int = 2
var jump_force: int = 10
var jump_count = 0
var jump_ongoing = false
var forward_acceleration = 0
var moving = false

func _physics_process(_delta):
	if !is_on_floor():
		velocity.y -= gravity
		if velocity.y > max_velocity:
			velocity.y = max_velocity
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		rotation_degrees.y -= Input.get_axis("move_left", "move_right") * rotation_speed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_force
		jump_ongoing = true
	if Input.is_action_just_released("jump") or jump_count == 20:
		jump_ongoing = false
		jump_count = 0
	if jump_ongoing:
		velocity.y += jump_force
		jump_count += 1
	if Input.is_action_pressed("move_forward"):
		moving = true
		if forward_acceleration <= 0.3:
			forward_acceleration += 0.01
	if Input.is_action_just_released("move_forward"):
		moving = false
	if !moving and forward_acceleration > 0:
		forward_acceleration -= 0.01
	position.z -= cos(deg_to_rad(rotation_degrees.y)) * forward_acceleration
	position.x -= sin(deg_to_rad(rotation_degrees.y)) * forward_acceleration
	velocity.z = 0
	velocity.x = 0
	move_and_slide()

extends RigidBody3D

@onready var car_mesh = $CarMesh
@onready var body_mesh = $CarMesh/CarBody
@onready var ground_ray = $CarMesh/RayCast3D
@onready var right_wheel = $CarMesh/TireFrontRight
@onready var left_wheel = $CarMesh/TireFrontLeft

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN
# Engine power
var acceleration = 35.0
# Turn amount, in degrees
var steering = 18.0
# How quickly the car turns
var turn_speed = 4.0
# Below this speed, the car doesn't turn
var turn_stop_limit = 0.75

# Variables for input valuess
var speed_input = 0
var turn_input = 0

func _physics_process(delta: float) -> void:
	car_mesh.position = position + sphere_offset

	if ground_ray.is_colliding():
		apply_central_force(-car_mesh.global_transform.basis.z * speed_input)

		
func _process(delta: float) -> void:
	if not ground_ray.is_colliding():
		return
	speed_input = Input.get_axis("move_backwards", "move_forward") * acceleration
	turn_input = Input.get_axis("move_right", "move_left") * deg_to_rad(steering)
	right_wheel.rotation.y = turn_input
	left_wheel.rotation.y = turn_input

	if linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		

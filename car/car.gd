# A cart like Player Controller. 
# by Loteque (Drew Billings)
# Copyright Drew Billings & Bria 2025
#
# [] add fiction value (separate from the weight, which is a weight for the floor movement values)
# [] change weight to gravity (this may be changed for low gravity cheats)
# [] add acceleration value (adds momentum)
# [] change speed/movement to "max speed" value
# [] add jump action with corresponding jump velocity
# [] When colliding to walls, bounce off of them with some momentum/speed taken away (you can't just immediately stop)
# [x] Remove the brake action, and make opposing directions brake instead
# [] Car body parralell to ground normals
extends CharacterBody3D

@export_range(1.0, 100.0, 0.5) var speed = 10.0
@export_range(0.0, 100.0, 1) var friction = 81.0
@export_range(1.0, 100.0, 0.5) var brake_strength = 27.5
@export_range(1.0, 100.0, 0.5) var decel = 6.5
@export_range(0.001, 10.0, 0.001) var rotation_speed = 10.0
@export_range(0.0, 1.0, 0.01) var joystick_cam_sensitivity = 0.01
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var cam_max_vert = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var cam_min_vert = PI/4
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cam_arm = %CamSpringArm

var brake_state = BrakeState.new()


func _capture_mouse():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
    cam_arm.global_position = global_position


func _update_cam_rotation_from_mouse(event: InputEvent):
    if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: return
    if event is InputEventMouseMotion:
        # rotation around Y
        cam_arm.rotation.y -= event.relative.x * (rotation_speed * .0001)
        cam_arm.rotation.y = wrapf(cam_arm.rotation.y, 0.0, TAU)
        # rotation around X
        cam_arm.rotation.x -= event.relative.y * (rotation_speed * .0001)
        cam_arm.rotation.x = clamp(cam_arm.rotation.x, cam_max_vert, cam_min_vert)


func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("capture_mouse") and not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        _capture_mouse()
    if (event.is_action_pressed("move_left") 
        or event.is_action_pressed("move_right") 
        or event.is_action_pressed("move_forward") 
        or event.is_action_pressed("move_backwards")
    ):        
        brake_state.update(event)
    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        _update_cam_rotation_from_mouse(event)


func _update_cam_rotation_from_joy():
    var _joy_input_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
    cam_arm.rotate_y(-_joy_input_direction.y * joystick_cam_sensitivity)
    cam_arm.rotate_x(-_joy_input_direction.x * joystick_cam_sensitivity)


func _physics_process(delta):
    _update_cam_rotation_from_joy()
    
    # movement
    var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
    var input_dir: Vector3 = Vector3(input_vec.x, 0, input_vec.y).normalized()
    var direction = input_dir.rotated(Vector3.UP, cam_arm.global_rotation.y)
    var rot_y_lerped = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)
    direction = direction.rotated(Vector3.UP, rot_y_lerped - rotation.y)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if brake_state.active:
        prints(brake_state.action, brake_state.active)
        velocity.x = move_toward(velocity.x, 0, brake_strength * delta * friction / 100.0)
        velocity.z = move_toward(velocity.z, 0, brake_strength * delta * friction / 100.0)                      
    elif direction:
        velocity.x = move_toward(velocity.x, direction.x * speed, (100.0 - friction) * delta)
        velocity.z = move_toward(velocity.z, direction.z * speed, (100.0 - friction) * delta)
        rotation.y = rot_y_lerped
    else:
        velocity.x = move_toward(velocity.x, 0, decel * delta * friction / 100.0)
        velocity.z = move_toward(velocity.z, 0, decel * delta * friction / 100.0)
    move_and_slide()


class BrakeState extends RefCounted:
    var action: InputEvent = null
    var active: bool = false
    
    func update(input_action: InputEvent) -> BrakeState:
        if not input_action:
            active = false
        if not action:
            action = input_action
            active = false
            return self
        var in_is_f: bool = input_action.is_action("move_forward")
        var in_is_b: bool = input_action.is_action("move_backwards")
        var in_is_l: bool = input_action.is_action("move_left")
        var in_is_r: bool = input_action.is_action("move_right")
        var a_is_f: bool = action.is_action("move_forward")
        var a_is_b: bool = action.is_action("move_backwards")
        var a_is_l: bool = action.is_action("move_left")
        var a_is_r: bool = action.is_action("move_right")
        var is_not_opposing_right_input = in_is_r and (a_is_r or a_is_f or a_is_b)
        var is_not_opposing_left_input = in_is_l and (a_is_l or a_is_f or a_is_b)
        var is_not_opposing_forward_input = in_is_f and (a_is_f or a_is_r or a_is_l)
        var is_not_opposing_backwards_input = in_is_b and (a_is_b or a_is_r or a_is_l)
        var is_not_opposing_input = (
            is_not_opposing_right_input 
            or is_not_opposing_left_input 
            or is_not_opposing_backwards_input 
            or is_not_opposing_forward_input
        )
        if is_not_opposing_input:
            active = false
            action = input_action
            return self
        active = true
        action = input_action
        return self

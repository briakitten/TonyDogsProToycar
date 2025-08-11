extends CharacterBody3D

@export_range(1.0, 100.0, 0.5) var speed = 10.0
@export_range(0.0, 100.0, 1) var weight = 81.0
@export_range(1.0, 100.0, 0.5) var brake = 27.5
@export_range(1.0, 100.0, 0.5) var decel = 6.5
@export_range(0.001, 10.0, 0.001) var rotation_speed = 10.0
@export_range(0.0, 1.0, 0.01) var joystick_cam_sensitivity = 0.01
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var cam_max_vert = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var cam_min_vert = PI/4

@onready var cam_arm = %CamSpringArm

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


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
    if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED: return
    _update_cam_rotation_from_mouse(event)


func _update_cam_rotation_from_joy():
    var _joy_input_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
    cam_arm.rotate_y(-_joy_input_direction.y * joystick_cam_sensitivity)
    cam_arm.rotate_x(-_joy_input_direction.x * joystick_cam_sensitivity)


func _physics_process(delta):
    _update_cam_rotation_from_joy()
    
    # movement
    var is_brake_pressed = Input.is_action_pressed("brake")
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
    direction = direction.rotated(Vector3.UP, cam_arm.global_rotation.y)
    var rot_y_lerped = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)
    direction = direction.rotated(Vector3.UP, rot_y_lerped - rotation.y)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if is_brake_pressed:
        velocity.x = move_toward(velocity.x, 0, brake * delta * weight / 100.0)
        velocity.z = move_toward(velocity.z, 0, brake * delta * weight / 100.0)                      
    elif direction:
        velocity.x = move_toward(velocity.x, direction.x * speed, (100.0 - weight) * delta)
        velocity.z = move_toward(velocity.z, direction.z * speed, (100.0 - weight) * delta)
        rotation.y = rot_y_lerped
    else:
        velocity.x = move_toward(velocity.x, 0, decel * delta * weight / 100.0)
        velocity.z = move_toward(velocity.z, 0, decel * delta * weight / 100.0)
    move_and_slide()

extends CharacterBody3D

@export var speed = 10.0
@export var rotation_speed = 30
@export_range(0.0, 1.0, .001) var mouse_cam_sensitivity = 0.005
@export_range(0.0, 1.0, .01) var joystick_cam_sensitivity = 0.1
@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var cam_min_vert = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var cam_max_vert = PI/4

@onready var cam_arm = %CamSpringArm

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _capture_mouse():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _ready():
    _capture_mouse()


func _update_cam_rotation(event: InputEvent):     
    if !Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: return
    if event is InputEventMouseMotion:
        # rotation around Y
        cam_arm.rotation.y -= event.relative.x * mouse_cam_sensitivity
        cam_arm.rotation.y = wrapf(cam_arm.rotation.y, 0.0, TAU)
        # rotation around X
        cam_arm.rotation.x -= event.relative.y * mouse_cam_sensitivity
        cam_arm.rotation.x = clamp(cam_arm.rotation.x, cam_min_vert, cam_max_vert)


func _unhandled_input(event: InputEvent):    
    _update_cam_rotation(event)


func _update_joy_direction():
    var _joy_input_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
    cam_arm.rotate_y(-_joy_input_direction.y * joystick_cam_sensitivity)
    cam_arm.rotate_x(-_joy_input_direction.x * joystick_cam_sensitivity)


func _process(_delta: float) -> void:
    cam_arm.global_position = global_position


func _physics_process(delta):
    _update_joy_direction()
    
    # movement
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
    direction = direction.rotated(Vector3.UP, cam_arm.global_rotation.y)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var rot_y_lerped = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)
        rotation.y = rot_y_lerped
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    move_and_slide()

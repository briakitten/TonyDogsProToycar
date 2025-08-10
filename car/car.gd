extends CharacterBody3D

@export var speed = 10.0
@export var rotation_speed = 30
@export var mouse_cam_sensitivity = 0.005
@export var joystick_cam_sensitivity = 0.1

@onready var model = %GreyBoxCar
@onready var cam_h = %CamH
@onready var cam_v = %CamV

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var h_input = 0.0
var v_input = 0.0
var _mouse_input_dir


func _ready():
    _capture_mouse()


func _update_cam_rotation(event: InputEvent):     
    if !Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: return
    if event is InputEventMouseMotion:
        h_input = -event.relative.x * mouse_cam_sensitivity
        v_input = -event.relative.y * mouse_cam_sensitivity


func _unhandled_input(event: InputEvent):
    _update_cam_rotation(event)


func _capture_mouse():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _release_mouse():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):

    # joystick
    _mouse_input_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
    cam_h.rotate_y(-_mouse_input_dir.x * joystick_cam_sensitivity)
    cam_v.rotate_x(-_mouse_input_dir.y * joystick_cam_sensitivity)

    # mouse
    cam_h.rotate_y(h_input)
    cam_v.rotate_x(v_input)

    # limit rotation on the x axsis
    cam_v.rotation.x = clamp(
        cam_v.rotation.x,
        deg_to_rad(-90),
        deg_to_rad(45)
    )
    h_input = 0.0
    v_input = 0.0
    
    # movement
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
    var direction = (cam_h.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
    if not is_on_floor():
        velocity.y -= gravity * delta
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var key_rotation = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), rotation_speed * delta)
        rotation.y = key_rotation + h_input
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
    move_and_slide()
    
    

class_name FPSController
extends CharacterBody3D

signal mouse_capture_changed(captured: bool)

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var acceleration: float = 35.0
@export var stopping_acceleration: float = 45.0
@export var air_acceleration: float = 8.0
@export var jump_speed: float = 6.0
@export var gravity: float = 18.0
@export_group("Stance")
@export var standing_height: float = 1.8
@export var crouching_height: float = 1.1
@export var standing_eye_height: float = 1.65
@export var crouching_eye_height: float = 0.95
@export_group("View")
## Radians per mouse pixel, independent of frame rate.
@export var mouse_sensitivity: float = 0.002
@export_range(60.0, 110.0) var field_of_view: float = 80.0
@export_range(0.1, 1.0) var aim_speed_multiplier: float = 0.65
@export var scale_sensitivity_with_fov: bool = true

var is_crouching: bool = false
var has_mouse_capture: bool = false
var is_aiming: bool = false
var _pitch: float = 0.0
var _jump_requested: bool = false
var _standing_query := PhysicsShapeQueryParameters3D.new()

@onready var body_shape: CollisionShape3D = $BodyShape
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
	# Each instance owns its mutable capsule; standing queries keep a full capsule.
	body_shape.shape = body_shape.shape.duplicate()
	var standing_capsule := body_shape.shape.duplicate() as CapsuleShape3D
	standing_capsule.height = standing_height
	_standing_query.shape = standing_capsule
	_standing_query.collision_mask = collision_mask
	_standing_query.exclude = [get_rid()]
	_standing_query.margin = 0.001
	camera.fov = field_of_view
	_set_crouching(false)
	set_mouse_capture(true)

func set_mouse_capture(captured: bool) -> void:
	has_mouse_capture = captured
	_jump_requested = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE
	mouse_capture_changed.emit(captured)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		set_mouse_capture(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("capture_mouse") and not has_mouse_capture:
		set_mouse_capture(true)
		get_viewport().set_input_as_handled()
	elif has_mouse_capture and event.is_action_pressed("jump"):
		_jump_requested = true
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and has_mouse_capture:
		apply_mouse_look(event.screen_relative)

func apply_mouse_look(relative_motion: Vector2) -> void:
	var sensitivity: float = mouse_sensitivity
	if scale_sensitivity_with_fov:
		sensitivity *= tan(deg_to_rad(camera.fov * 0.5)) / tan(deg_to_rad(field_of_view * 0.5))
	rotation.y = wrapf(rotation.y - relative_motion.x * sensitivity, -PI, PI)
	_pitch = clampf(_pitch - relative_motion.y * sensitivity, deg_to_rad(-89.0), deg_to_rad(89.0))
	head.rotation.x = _pitch

func set_aiming(value: bool) -> void:
	is_aiming = value

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		set_mouse_capture(false)

func _physics_process(delta: float) -> void:
	var controls_active: bool = has_mouse_capture
	var jump_requested: bool = _jump_requested
	_jump_requested = false
	var wants_crouch: bool = controls_active and Input.is_action_pressed("crouch")
	if wants_crouch and not is_crouching:
		_set_crouching(true)
	elif not wants_crouch and is_crouching and can_stand():
		_set_crouching(false)
	var input_vector := Vector2.ZERO
	if controls_active:
		input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Root yaw follows the camera; pitch never tilts the movement plane.
	var direction: Vector3 = global_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	var speed: float = walk_speed
	if is_crouching:
		speed = crouch_speed
	elif controls_active and Input.is_action_pressed("sprint") and not is_aiming:
		speed = sprint_speed
	if is_aiming:
		speed *= aim_speed_multiplier
	var response: float = acceleration if not input_vector.is_zero_approx() else stopping_acceleration
	if not is_on_floor():
		response = air_acceleration
	var horizontal := Vector2(velocity.x, velocity.z).move_toward(Vector2(direction.x, direction.z) * speed, response * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.y
	if is_on_floor():
		velocity.y = 0.0
		if controls_active and jump_requested and not is_crouching:
			velocity.y = jump_speed
	else:
		velocity.y -= gravity * delta
	move_and_slide()

func can_stand() -> bool:
	_standing_query.transform = global_transform
	_standing_query.transform.origin += global_basis * Vector3(0.0, standing_height * 0.5 + 0.015, 0.0)
	return get_world_3d().direct_space_state.intersect_shape(_standing_query, 1).is_empty()

func _set_crouching(crouching: bool) -> void:
	is_crouching = crouching
	var height: float = crouching_height if crouching else standing_height
	(body_shape.shape as CapsuleShape3D).height = height
	body_shape.position.y = height * 0.5
	head.position.y = crouching_eye_height if crouching else standing_eye_height

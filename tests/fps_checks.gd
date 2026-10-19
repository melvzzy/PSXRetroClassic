extends SceneTree
## Integration checks against the real scene and physics, without a test plugin.

var failures: int = 0
var checks: int = 0
var world: Node3D
var player: FPSController

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	world = load("res://scenes/startup.tscn").instantiate() as Node3D
	root.add_child(world)
	player = world.get_node("Player") as FPSController
	await _frames(20)
	_expect(player.is_on_floor(), "Spawn settles on the floor")
	_expect(is_equal_approx(player.camera.fov, player.field_of_view), "Configured FOV is applied")
	player.apply_mouse_look(Vector2(100000.0, -100000.0))
	_expect(absf(player.rotation.y) <= PI and is_equal_approx(player.head.rotation.x, deg_to_rad(89.0)), "Yaw wraps and pitch clamps")
	player.apply_mouse_look(Vector2(0.0, 100000.0))
	_expect(is_equal_approx(player.head.rotation.x, deg_to_rad(-89.0)), "Pitch clamps in both directions")
	player.apply_mouse_look(Vector2(0.0, -deg_to_rad(89.0) / player.mouse_sensitivity))
	player.rotation.y = 0.0
	player.set_mouse_capture(true)
	Input.action_press("move_forward")
	await _frames(20)
	_expect(player.velocity.z < -4.9, "Forward accelerates to walking speed")
	Input.action_release("move_forward")
	await _frames(12)
	_expect(Vector2(player.velocity.x, player.velocity.z).length() < 0.01, "Release stops horizontal motion")
	await _place(Vector3(0.0, 0.02, 4.0), PI / 2.0)
	Input.action_press("move_forward")
	await _frames(15)
	_expect(player.velocity.x < -4.9 and absf(player.velocity.z) < 0.05, "Movement follows view yaw")
	Input.action_press("sprint")
	await _frames(15)
	_expect(Vector2(player.velocity.x, player.velocity.z).length() > 7.9, "Sprint reaches configured speed")
	_release_actions()
	await _place(Vector3(0.0, 0.02, 4.0))
	Input.action_press("move_forward")
	Input.action_press("move_right")
	await _frames(20)
	_expect(Vector2(player.velocity.x, player.velocity.z).length() <= player.walk_speed + 0.01, "Diagonal movement has no speed boost")
	_release_actions()
	await _place(Vector3(0.0, 0.02, 4.0))
	_key(KEY_SPACE, true)
	await _frames(1)
	_key(KEY_SPACE, false)
	await _frames(10)
	_expect(player.position.y > 0.5, "Jump leaves the ground")
	_key(KEY_SPACE, true)
	await _frames(1)
	_key(KEY_SPACE, false)
	_expect(player.velocity.y < player.jump_speed - 1.0, "No second jump in midair")
	await _frames(60)
	_expect(player.is_on_floor() and absf(player.position.y) < 0.05, "Gravity returns player to the floor")
	Input.action_press("crouch")
	await _frames(2)
	_expect(player.is_crouching and is_equal_approx((player.body_shape.shape as CapsuleShape3D).height, player.crouching_height) and player.head.position.y < player.standing_eye_height and player.head.position.y > player.crouching_eye_height, "Crouch resizes collision immediately while visual eye transitions")
	Input.action_press("move_forward")
	Input.action_press("sprint")
	_key(KEY_SPACE, true)
	await _frames(10)
	_expect(is_equal_approx(Vector2(player.velocity.x, player.velocity.z).length(), player.crouch_speed), "Crouch speed takes priority over sprint")
	_expect(player.is_on_floor(), "Crouching prevents jumping")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	_key(KEY_SPACE, false)
	await _place(Vector3(-4.0, 0.02, -1.0))
	Input.action_release("crouch")
	await _frames(4)
	_expect(player.is_crouching and not player.can_stand(), "Low ceiling prevents standing")
	await _place(Vector3(-4.0, 0.02, 3.0))
	await _frames(3)
	_expect(not player.is_crouching, "Leaving the ceiling allows standing")
	await _place(Vector3(4.0, 1.8, -1.0))
	await _frames(40)
	_expect(player.is_on_floor() and player.get_floor_normal().y > 0.9, "Player settles on the ramp")
	Input.action_press("move_back")
	await _frames(25)
	_expect(player.is_on_floor() and player.position.z > 0.5, "Ground snapping follows the descending ramp")
	_release_actions()
	await _place(Vector3(0.0, 0.02, -3.6))
	Input.action_press("move_forward")
	await _frames(30)
	_expect(player.position.z > -4.5, "Wall blocks movement")
	_release_actions()
	await _place(Vector3(0.0, 0.02, 0.0))
	var interactor := player.get_node("Head/Camera3D/Interactor") as Interactor
	var target := world.get_node("Switch/InteractionTarget") as InteractionTarget
	player.apply_mouse_look(Vector2(0.0, 0.16 / player.mouse_sensitivity))
	await _frames(3)
	_expect(interactor.get_collider() == world.get_node("Switch"), "Camera ray hits the switch")
	_key(KEY_E, true)
	await _frames(1)
	_key(KEY_E, false)
	_expect(world.get_node("Switch").get("active") == true, "E triggers visible switch feedback")
	target.enabled = false
	_key(KEY_E, true)
	await _frames(1)
	_key(KEY_E, false)
	_expect(world.get_node("Switch").get("active") == true, "Disabled target rejects interaction")
	target.enabled = true
	await _place(Vector3(0.0, 0.02, 4.0))
	_key(KEY_E, true)
	await _frames(1)
	_key(KEY_E, false)
	_expect(world.get_node("Switch").get("active") == true, "Out-of-range target cannot be used")
	await _place(Vector3(0.0, 0.02, -6.0), PI)
	await _frames(3)
	_expect(interactor.get_collider() == world.get_node("Wall"), "World geometry occludes the interaction ray")
	await _place(Vector3(0.0, 0.02, 0.0))
	var escape := InputEventAction.new()
	escape.action = "release_mouse"
	escape.pressed = true
	player._unhandled_input(escape)
	_expect(not player.has_mouse_capture, "Escape releases gameplay capture")
	var previous_yaw: float = player.rotation.y
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(200.0, 100.0)
	player._unhandled_input(motion)
	_expect(is_equal_approx(player.rotation.y, previous_yaw), "Released mouse cannot rotate the view")
	Input.action_press("move_forward")
	_key(KEY_E, true)
	await _frames(5)
	_expect(Vector2(player.velocity.x, player.velocity.z).length() < 0.01, "Released mouse gates movement input")
	_expect(world.get_node("Switch").get("active") == true and world.get_node("HUD/Prompt").get("text") == "", "Released mouse gates interaction and hides its prompt")
	_release_actions()
	var recapture := InputEventAction.new()
	recapture.action = "capture_mouse"
	recapture.pressed = true
	player._unhandled_input(recapture)
	_expect(player.has_mouse_capture, "Click action restores gameplay capture")
	_expect(not world.get_node("HUD/Help").visible and not world.get_node("HUD/Quit").visible, "Captured HUD hides help and exit overlay")
	player._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _frames(2)
	_expect(not player.has_mouse_capture and world.get_node("HUD/Help").visible, "Focus loss releases capture and reveals help")
	_expect(not world.get_node("HUD/Crosshair").visible, "Released capture hides the crosshair")
	player._unhandled_input(recapture)
	_expect(player.get_node_or_null("CharacterVisuals") != null and player.camera.get_node_or_null("ViewmodelMount") != null, "Player has replaceable visual attachment points")
	for name: String in ["CrateA", "CrateB", "CrateC"]:
		var prop := world.get_node(name) as RigidBody3D
		_expect(prop.position.y > 0.25 and prop.position.y < 0.4, name + " settles on the floor")
	_release_actions()
	# Inputs received by the released UI must not leak into a later capture in
	# the same physics tick. Use real key/mouse events, not direct state changes.
	await _place(Vector3(0.0, 0.02, 0.0))
	player.set_mouse_capture(false)
	_expect(world.get_node("HUD/Prompt").text == "", "Capture release clears interaction feedback without another physics tick")
	var switch_before: bool = world.get_node("Switch").active
	_key(KEY_E, true)
	_key(KEY_SPACE, true)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(640, 360)
	Input.parse_input_event(click)
	await _frames(2)
	_expect(world.get_node("Switch").active == switch_before, "UI E cannot leak through same-tick mouse recapture")
	_expect(player.is_on_floor(), "UI Space cannot jump on same-tick mouse recapture")
	_key(KEY_E, false)
	_key(KEY_SPACE, false)
	click = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = Vector2(640, 360)
	Input.parse_input_event(click)
	print("FPS checks: %d passed, %d failed" % [checks - failures, failures])
	world.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _place(position: Vector3, yaw: float = 0.0) -> void:
	player.position = position
	player.rotation.y = yaw
	player.velocity = Vector3.ZERO
	await _frames(3)

func _release_actions() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "sprint", "jump", "crouch", "interact"]:
		Input.action_release(action)

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

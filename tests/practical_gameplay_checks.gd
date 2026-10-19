extends SceneTree

var checks: int = 0
var failures: int = 0
var game: Node3D
var actor: FPSController
var interactor: Interactor
var gun: TestFirearm

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://scenes/startup.tscn").instantiate()
	root.add_child(game)
	actor = game.get_node("Player")
	interactor = actor.get_node("Head/Camera3D/Interactor")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	await _frames(20)
	var door: Node3D = game.get_node("WorkshopDoor")
	var control: StaticBody3D = door.get_node("Control")
	var panel: AnimatableBody3D = door.get_node("Panel")
	var target: InteractionTarget = control.get_node("InteractionTarget")
	_expect(door.is_open and is_equal_approx(panel.position.x, -2.85), "F5 keeps the existing workshop passage open")
	await _look(Vector3(4.35, 0.05, -1.8), control.global_position)
	_expect(interactor.get_collider() == control and game.get_node("HUD/Prompt").text == target.prompt, "Camera ray and HUD identify the actual door control")
	await _look(Vector3(7.5, 0.05, 2.5), Vector3(5.5, 1.5, -3.72))
	await _capture("open")
	await _look(Vector3(4.35, 0.05, -1.8), control.global_position)
	_press(KEY_E)
	await _frames(1)
	_expect(not door.is_open and game.get_node("HUD/Prompt").text == target.prompt and target.prompt.contains("öffnen"), "E starts closing and refreshes the action prompt immediately")
	_press(KEY_E, true)
	await _frames(2)
	_expect(not door.is_open, "Keyboard echo cannot reverse a moving door")
	await _frames(105)
	_expect(is_zero_approx(panel.position.x) and not door.is_physics_processing(), "Door reaches its closed position and stops processing")
	await _look(Vector3(6, 0.05, 1), Vector3(6, 1.5, -3.72))
	await _capture("closed")
	await _look(Vector3(6, 0.12, -1.8), Vector3(6, 1.5, -5))
	_expect(interactor.get_collider() == panel, "Closed visible door blocks the interaction ray")
	var ray := PhysicsRayQueryParameters3D.create(actor.camera.global_position, Vector3(6, 1.5, -6), 3)
	ray.exclude = [actor.get_rid()]
	_expect(game.get_world_3d().direct_space_state.intersect_ray(ray).get("collider") == panel, "The same closed panel blocks the firearm collision mask")
	Input.action_press("move_forward")
	await _frames(40)
	Input.action_release("move_forward")
	_expect(actor.position.z > -3.4, "Closed door physically blocks ordinary walking")
	_press(KEY_E)
	await _frames(110)
	_expect(door.is_open and is_equal_approx(panel.position.x, -2.85), "Door surface can open it from the passage")
	Input.action_press("move_forward")
	await _frames(38)
	Input.action_release("move_forward")
	_expect(actor.position.z < -4.2 and actor.is_on_floor(), "Opened doorway is traversable without jumping")
	# A close request while standing in the swept path must reopen without pushing.
	await _look(Vector3(6, 0.12, -3.72), control.global_position)
	target.interact(actor)
	await _frames(115)
	_expect(door.is_open and is_equal_approx(panel.position.x, -2.85), "Closing reverses safely when the player obstructs the path")
	_expect(absf(actor.position.x - 6.0) < 0.03, "Door does not shove the player sideways")
	await _capture("blocked")
	await _look(Vector3(4.35, 0.05, -1.8), control.global_position)
	var prop: RigidBody3D = game.get_node("StreetKiste")
	var original: Transform3D = prop.global_transform
	prop.freeze = true
	prop.global_position = Vector3(6, 0.12, -3.72)
	await _frames(3)
	_press(KEY_E)
	await _frames(115)
	_expect(door.is_open and is_equal_approx(panel.position.x, -2.85), "Loose physics props also prevent unsafe closing")
	prop.global_transform = original
	prop.freeze = false
	await _frames(3)
	# Reverse a real movement rather than waiting for its endpoint.
	_press(KEY_E)
	await _frames(12)
	_press(KEY_E)
	await _frames(110)
	_expect(door.is_open and is_equal_approx(panel.position.x, -2.85), "Distinct E during travel reverses smoothly to the open endpoint")
	# Queue E for the displayed door, turn away before the physics query.
	_press(KEY_E)
	actor.rotation.y += PI
	await _frames(3)
	_expect(door.is_open and game.get_node("HUD/Prompt").text.is_empty(), "Queued E is discarded after losing its displayed target")
	await _look(Vector3(4.35, 0.05, 1.0), control.global_position)
	_press(KEY_E)
	await _frames(3)
	_expect(door.is_open and game.get_node("HUD/Prompt").text.is_empty(), "Out-of-range use is rejected")
	await _look(Vector3(4.35, 0.05, -1.8), control.global_position)
	_press(KEY_E)
	actor.set_mouse_capture(false)
	await _frames(3)
	_expect(door.is_open and game.get_node("HUD/Prompt").text.is_empty(), "Capture release clears queued interaction and HUD")
	actor.set_mouse_capture(true)
	await _frames(3)
	_expect(door.is_open, "Recapture cannot replay E")
	var switch_body: StaticBody3D = game.get_node("Switch")
	await _look(Vector3(10, 0.05, -11), switch_body.global_position)
	var light: OmniLight3D = game.get_node("FoundationDetails/WorkshopLight")
	_expect(interactor.get_collider() == switch_body and is_equal_approx(light.light_energy, 0.15), "Existing generator control is reachable and starts dimmed")
	gun.magazine -= 1
	_press(KEY_R)
	await _frames(3)
	_expect(gun.is_reloading, "Existing firearm can reload while using a switch")
	_press(KEY_E)
	await _frames(3)
	_expect(switch_body.active and is_equal_approx(light.light_energy, 1.0) and gun.is_reloading, "E changes real workshop lighting without interrupting reload")
	_expect(game.get_node("HUD/Prompt").text.contains("ausschalten"), "Light prompt describes the next action")
	_press(KEY_E)
	await _frames(3)
	_expect(not switch_body.active and is_equal_approx(light.light_energy, 0.15), "Repeated distinct presses toggle the light back")
	await _frames(160)
	_expect(not gun.is_reloading and gun.weapon_profiles.size() == 8, "Reload finishes normally and all eight profiles remain available")
	_press(KEY_X)
	await _frames(20)
	_press(KEY_E)
	await _frames(3)
	_expect(gun.is_holstered and switch_body.active, "Interaction with a holstered weapon never draws or fires it")
	_press(KEY_X)
	await _frames(20)
	Input.action_press("aim")
	await _frames(15)
	_press(KEY_E)
	await _frames(3)
	_expect(gun.is_aiming and not switch_body.active, "Interaction while ADS preserves aiming and changes only the light")
	Input.action_release("aim")
	await _frames(15)
	await _capture("generator")
	game.queue_free()
	await process_frame
	print("Practical gameplay checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)

func _look(position: Vector3, point: Vector3) -> void:
	actor.position = position
	actor.velocity = Vector3.ZERO
	actor.get_node("Head").rotation = Vector3.ZERO
	actor.camera.rotation = Vector3.ZERO
	var direction: Vector3 = point - (position + Vector3(0, actor.standing_eye_height, 0))
	actor.rotation.y = atan2(-direction.x, -direction.z)
	actor.get_node("Head").rotation.x = atan2(direction.y, Vector2(direction.x, direction.z).length())
	await _frames(5)

func _press(code: int, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	Input.parse_input_event(event)
	if not echo:
		event = InputEventKey.new()
		event.physical_keycode = code
		Input.parse_input_event(event)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/practical_gameplay")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/practical_gameplay/%s.png" % label) == OK, "Rendered " + label)

func _expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

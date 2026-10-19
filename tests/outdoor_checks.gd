extends SceneTree
var checks: int = 0
var failures: int = 0
var shots: int = 0
var world: Node3D
var actor: FPSController
var gun: TestFirearm
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	world = load("res://scenes/startup.tscn").instantiate()
	root.add_child(world)
	actor = world.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	gun.fired.connect(func() -> void: shots += 1)
	await _frames(40)
	_expect(actor.is_on_floor() and actor.position.y > -0.1, "F5 spawns safely on outdoor ground")
	_expect(world.has_node("OutdoorAssets/Buildings/Urban Hangar") and world.has_node("Yard/CargoShell"), "F5 loads the actual environment, not the fallback")
	_expect(gun.active_weapon == 1 and gun.weapon_profiles.size() == 8, "Startup keeps the AS Val default and all eight profiles")
	for path: String in ["IndustrialKiste", "StreetFass", "StreetKiste", "Yard/MiddleRoad"]:
		var valid: bool = false
		for mesh: MeshInstance3D in world.get_node(path).find_children("*","MeshInstance3D",true,false):
			valid = valid or (mesh.is_visible_in_tree() and mesh.get_active_material(0) != null)
		_expect(valid, path + ": saved scene contains visible imported geometry")
	_expect(world.get_node("Yard").find_children("*", "MeshInstance3D", true, false).size() > 15, "Repeated vegetation survives scene serialization")
	_key(KEY_SPACE)
	await _frames(8)
	_expect(actor.position.y > 0.3, "Jump works on the outdoor ground")
	await _frames(60)
	Input.action_press("crouch")
	await _frames(8)
	var crouched: bool = actor.is_crouching
	Input.action_release("crouch")
	await _frames(14)
	_expect(crouched and not actor.is_crouching, "Outdoor crouch and standing retain the existing collision behavior")
	await _capture("spawn")
	Input.action_press("move_forward")
	await _frames(90)
	Input.action_release("move_forward")
	_expect(actor.position.z < 8.0 and actor.is_on_floor(), "Continuous road is walkable from spawn")
	# Traverse the real cargo opening and threshold with ordinary movement.
	actor.position = Vector3(6,0.12,-2.5)
	actor.velocity = Vector3.ZERO
	await _frames(12)
	Input.action_press("move_forward")
	await _frames(75)
	Input.action_release("move_forward")
	_expect(actor.position.z < -6.0 and actor.is_on_floor(), "Cargo threshold and interior are walkable without jumping")
	await _capture("cargo")
	Input.action_press("move_forward")
	await _frames(75)
	Input.action_release("move_forward")
	_expect(actor.position.z < -12.2 and actor.is_on_floor(), "Both cargo ends remain open and traversable")
	actor.position = Vector3(-3,0.05,-9)
	actor.velocity = Vector3.ZERO
	actor.rotation.y = PI * 0.5
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(100)
	Input.action_release("move_forward")
	_expect(actor.position.x > -8.5, "Closed hall collision blocks passage through its wall")
	actor.position = Vector3(19,0.05,-1)
	actor.rotation.y = -PI * 0.5
	actor.velocity = Vector3.ZERO
	await _frames(10)
	Input.action_press("move_forward")
	await _frames(40)
	Input.action_release("move_forward")
	_expect(actor.position.x < 19.6 and actor.is_on_floor(), "Visible perimeter prevents leaving the playable ground")
	actor.position = Vector3(10,0.05,-11.1)
	actor.rotation.y = 0.0
	actor.velocity = Vector3.ZERO
	await _frames(20)
	_key(KEY_E)
	await _frames(3)
	_expect(world.get_node("Switch").get_node("InteractionTarget") != null and world.get_node("Switch/Status").text != "Schalter: AUS", "Existing E interaction works at the generator")
	await _capture("generator")
	# Every weapon fires into the real outdoor target through the camera query.
	for index: int in range(8):
		_key(KEY_1 + index)
		await _frames(25)
		actor.position = Vector3(-1.4,0.05,-12.0)
		actor.rotation = Vector3.ZERO
		actor.get_node("Head").rotation = Vector3.ZERO
		actor.velocity = Vector3.ZERO
		await _frames(15)
		var hits: int = world.get_node("Target").hit_count
		var before: int = shots
		_button(true)
		await _frames(2)
		_button(false)
		_expect(shots == before+1 and world.get_node("Target").hit_count == hits+1, gun.test_profile.display_name + ": outdoor hitscan and ammo remain functional")
		await _frames(15)
		Input.action_press("aim")
		await _frames(20)
		_expect(gun.is_aiming and actor.is_aiming, gun.test_profile.display_name + ": outdoor ADS")
		Input.action_release("aim")
		_key(KEY_R)
		await _frames(2)
		_expect(gun.is_reloading, gun.test_profile.display_name + ": outdoor reload starts")
	# Real rigid-body impulse from the existing camera-based shot.
	_key(KEY_1)
	await _frames(25)
	actor.position = Vector3(9,0.05,-2)
	actor.rotation = Vector3.ZERO
	actor.get_node("Head").rotation.x = -0.35
	actor.velocity = Vector3.ZERO
	await _frames(5)
	var prop: RigidBody3D = world.get_node("IndustrialKiste")
	var query := PhysicsRayQueryParameters3D.create(actor.camera.global_position, prop.global_position+Vector3(0,0.4,0), 3)
	query.exclude = [actor.get_rid()]
	var result: Dictionary = world.get_world_3d().direct_space_state.intersect_ray(query)
	_expect(not result.is_empty() and result.collider == prop, "Imported physical crate is reachable by world/prop ray masks")
	var direction: Vector3 = prop.global_position+Vector3(0,0.4,0)-actor.camera.global_position
	actor.get_node("Head").rotation.x = atan2(direction.y, Vector2(direction.x,direction.z).length())
	_button(true)
	await _frames(2)
	_button(false)
	_expect(prop.linear_velocity.length() > 0.1, "Real firearm shot imparts an impulse to the imported crate")
	_key(KEY_X)
	await _frames(20)
	_expect(gun.is_holstered, "Outdoor holster remains functional")
	_key(KEY_X)
	await _frames(20)
	_expect(gun.is_weapon_ready(), "Outdoor draw remains functional")
	actor.position = Vector3(0,0.05,13)
	actor.rotation = Vector3.ZERO
	actor.get_node("Head").rotation = Vector3.ZERO
	actor.velocity = Vector3.ZERO
	await _frames(20)
	await _capture("yard")
	# A rendered layout overview supplements the actual first-person captures.
	if OS.get_cmdline_user_args().has("--capture"):
		var camera := Camera3D.new()
		world.add_child(camera)
		camera.position = Vector3(32,31,36)
		camera.look_at(Vector3(0,0,0))
		camera.current = true
		await _capture("layout")
	world.queue_free()
	await process_frame
	print("Outdoor checks: %d passed, %d failed" % [checks-failures,failures])
	quit(1 if failures else 0)
func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame
func _key(code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.physical_keycode = code
	Input.parse_input_event(event)
func _button(value: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = value
	Input.parse_input_event(event)
func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/outdoor")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/outdoor/%s.png" % label) == OK, "Rendered "+label)
func _expect(value: bool, text: String) -> void:
	checks += 1
	if value:
		print("PASS: "+text)
	else:
		failures += 1
		push_error("FAIL: "+text)

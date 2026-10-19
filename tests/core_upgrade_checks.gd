extends SceneTree
## Real F5 scene, input events, fixed-tick cadence and interruption regressions.
var checks: int = 0
var failures: int = 0
var shots: int = 0
var game: Node3D
var actor: FPSController
var gun: TestFirearm

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://scenes/startup.tscn").instantiate()
	game.test_weapon = 0
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	gun.fired.connect(func() -> void: shots += 1)
	await _frames(20)
	for index: int in range(8):
		_key(KEY_1 + index)
		await _frames(25)
		var profile: TestWeaponProfile = gun.test_profile
		var label: String = profile.display_name + ": "
		_expect(gun.automatic_fire == (index not in [0, 2]), label + "appropriate configured firing mode")
		await _capture("hip_%d" % index)
		var before: int = shots
		var ammo: int = gun.magazine
		var start_tick: int = Engine.get_physics_frames()
		_button(true)
		await _frames(40)
		_button(false)
		var fired: int = shots - before
		# A rendered frame may contain several physics ticks; measure actual elapsed ticks.
		var elapsed_ticks: int = Engine.get_physics_frames() - start_tick
		var expected: int = mini(ammo, 1 + int(floor(float(elapsed_ticks - 1) / Engine.physics_ticks_per_second / gun.shot_interval))) if gun.automatic_fire else 1
		_expect(absi(fired - expected) <= (1 if gun.automatic_fire else 0) and fired > 0, label + "held trigger respects physics-time cadence (%d shots / %d ticks)" % [fired, elapsed_ticks])
		_expect(gun.magazine == ammo - fired, label + "one round per emitted shot")
		var after: int = shots
		await _frames(25)
		_expect(shots == after and gun._recoil.length() < 0.002, label + "release stops burst and recoil recovers")
		Input.action_press("aim")
		await _frames(40)
		var view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
		var sight: Node3D = view.model.get_node("SightLine")
		_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, label + "settled ADS centers actual sight marker")
		_expect(gun.get_node("Visuals/Muzzle").global_transform.is_equal_approx(view.model.get_node("Muzzle").global_transform), label + "muzzle follows presented geometry")
		await _capture("ads_%d" % index)
		_button(true)
		await _frames(2)
		_button(false)
		_expect(gun._recoil.x > 0.0 and gun._recoil.x <= deg_to_rad(gun.max_recoil_degrees), label + "ADS recoil remains bounded")
		await _capture("fire_%d" % index)
		Input.action_release("aim")
	# Burst cancellation through reload, switch, draw, focus and UI input.
	_key(KEY_5)
	await _frames(25)
	_button(true)
	await _frames(14)
	_key(KEY_R)
	await _frames(3)
	var count: int = shots
	var total: int = gun.magazine + gun.reserve
	_expect(gun.is_reloading and not gun._automatic_firing and not gun.is_aiming, "Reload cancels a held automatic burst")
	await _frames(50)
	_expect(shots == count and gun.visuals.position.y < -0.03 and absf(gun.visuals.rotation.z) > 0.08, "Reload has a restrained whole-weapon service gesture without firing")
	await _capture("reload")
	await _frames(100)
	_expect(not gun.is_reloading and shots == count and gun.magazine + gun.reserve == total, "Held fire cannot resume after reload; ammunition conserved")
	_button(false)
	await _frames(2)
	_button(true)
	await _frames(12)
	_expect(shots > count, "Fresh press resumes automatic fire after reload")
	_key(KEY_7)
	await _frames(25)
	count = shots
	await _frames(15)
	_expect(gun.active_weapon == 6 and shots == count and not gun._automatic_firing, "Switching while held never starts a burst on the new weapon")
	_button(false)
	await _frames(2)
	_button(true)
	await _frames(10)
	_key(KEY_X)
	await _frames(25)
	count = shots
	await _capture("holstered")
	_key(KEY_X)
	await _frames(25)
	_expect(gun.is_weapon_ready() and shots == count, "Holster/draw cancels held automatic fire")
	_button(false)
	await _frames(2)
	_button(true)
	await _frames(10)
	actor.set_mouse_capture(false)
	count = shots
	actor.set_mouse_capture(true)
	await _frames(25)
	_expect(shots == count and not gun._automatic_firing, "Focus recapture cannot resume a held burst")
	_button(false)
	await _frames(3)
	# A UI-consumed press updates Input state but must not start polling-based fire.
	Input.action_press("fire")
	await _frames(20)
	_expect(shots == count, "Input polling alone cannot fire an automatic weapon")
	Input.action_release("fire")
	await _frames(3)
	gun.magazine = 2
	_button(true)
	await _frames(35)
	_expect(gun.magazine == 0 and shots == count + 2 and not gun._automatic_firing, "Empty automatic weapon stops exactly at zero rounds")
	_button(false)
	# Movement uses the unchanged outpost floor; no test collision fixtures added.
	actor.position = Vector3(0, 0.02, 9)
	actor.velocity = Vector3.ZERO
	actor.rotation = Vector3.ZERO
	await _frames(8)
	Input.action_press("move_forward")
	await _frames(15)
	_expect(absf(actor.velocity.z + actor.walk_speed) < 0.05, "Walking reaches configured speed promptly")
	Input.action_press("sprint")
	await _frames(15)
	_expect(actor.is_sprinting and absf(actor.velocity.z + actor.sprint_speed) < 0.05, "Sprint transition preserves responsive acceleration")
	var moving_view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
	_expect(moving_view._movement_pose.length() > 0.005 and moving_view._movement_pose.length() < 0.04
		and moving_view._movement_rotation.length() < 0.08 and is_zero_approx(actor.head.rotation.x),
		"Sprint feedback is restrained and affects the weapon, not mouse aim")
	await _capture("sprint")
	Input.action_press("aim")
	await _frames(18)
	_expect(not actor.is_sprinting and actor.is_aiming and Vector2(actor.velocity.x, actor.velocity.z).length() <= actor.walk_speed * actor.aim_speed_multiplier + 0.05, "ADS overrides sprint while moving")
	_expect(moving_view._movement_pose.length() < 0.002, "ADS suppresses movement presentation while walking")
	Input.action_release("aim")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	await _frames(20)
	_expect(Vector2(actor.velocity.x, actor.velocity.z).length() < 0.01, "Release brakes cleanly without drifting")
	_expect(moving_view._movement_pose.length() < 0.001, "Weapon movement settles smoothly after stopping")
	var interactor: Interactor = actor.get_node("Head/Camera3D/Interactor")
	var repeated_interact := InputEventKey.new()
	repeated_interact.physical_keycode = KEY_E
	repeated_interact.pressed = true
	repeated_interact.echo = true
	interactor._unhandled_input(repeated_interact)
	_expect(not interactor._interaction_requested, "OS key repeat cannot queue repeated interactions")
	# Enter the ground from a small fall; the fresh jump press is buffered.
	actor.position = Vector3(0, 0.12, 9)
	actor.velocity = Vector3(0, -2, 0)
	await _frames(1)
	_key(KEY_SPACE)
	await _frames(5)
	_expect(actor.velocity.y > 3.0 and not actor.is_on_floor(), "Fresh jump just before landing is buffered into takeoff")
	await _frames(70)
	_expect(actor.is_on_floor(), "Buffered jump lands normally")
	# Walk-off grace is exercised without replacing world geometry.
	actor.position.y = 0.07
	actor.velocity = Vector3.ZERO
	await _frames(1)
	_key(KEY_SPACE)
	await _frames(2)
	_expect(actor.velocity.y > 4.0, "Short ground grace accepts a near-ground jump")
	await _frames(70)
	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_SPACE
	echo.pressed = true
	echo.echo = true
	Input.parse_input_event(echo)
	await _frames(2)
	_expect(actor.is_on_floor(), "OS key repeat cannot trigger another jump")
	echo = InputEventKey.new()
	echo.physical_keycode = KEY_SPACE
	Input.parse_input_event(echo)
	Input.action_press("crouch")
	await _frames(2)
	_key(KEY_SPACE)
	await _frames(2)
	Input.action_release("crouch")
	await _frames(3)
	_expect(actor.is_on_floor(), "Crouched jump does not leak through a quick stand transition")
	actor.set_mouse_capture(false)
	_expect(gun._automatic_firing == false and actor._jump_buffer == 0.0, "Capture loss clears firearm and buffered jump requests")
	game.queue_free()
	await process_frame
	print("Core upgrade checks: %d passed, %d failed" % [checks - failures, failures])
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

func _button(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	Input.parse_input_event(event)

func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/core_upgrade")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/core_upgrade/%s.png" % label) == OK, "Rendered " + label)

func _expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

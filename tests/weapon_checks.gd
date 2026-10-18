extends SceneTree
## Exercises the real input map, scene, physics queries and HUD without plugins.
var failures: int = 0
var checks: int = 0
var shots: int = 0
var hits: int = 0
var shot_pitch: float = 0.0
var world: Node3D
var player: FPSController
var weapon: TestFirearm

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	world = load("res://scenes/startup.tscn").instantiate() as Node3D
	root.add_child(world)
	player = world.get_node("Player") as FPSController
	weapon = player.get_node("Head/Camera3D/ViewmodelMount/TestFirearm") as TestFirearm
	weapon.fired.connect(_on_fired)
	weapon.hit_confirmed.connect(func() -> void: hits += 1)
	await _place(Vector3(-1.4, 0.02, 0.0))
	_expect(weapon.magazine == 12 and weapon.reserve == 48, "Initial ammo and reserve are configured")
	_expect(world.get_node("HUD/Ammo").text == "12 / 48", "HUD initializes from actual weapon state")
	var environment: Environment = world.get_node("WorldEnvironment").environment
	_expect(environment.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR and environment.ambient_light_energy > 0.0, "Neutral ambient lighting does not depend on a missing sky")
	_expect(world.get_node("Sun").shadow_enabled and ProjectSettings.get_setting("rendering/renderer/rendering_method") == "forward_plus", "Forward+ and directional shadows stay configured")
	_expect(weapon.get_node_or_null("Visuals/ModelMount/Placeholder") != null and weapon.get_node_or_null("Visuals/Muzzle") != null and weapon.get_node_or_null("Visuals/AudioMount") != null, "Replaceable model, muzzle and audio attachment points exist")
	await _reload_key()
	_expect(not weapon.is_reloading, "Full magazine rejects reload")
	await _click()
	_expect(shots == 1 and weapon.magazine == 11 and weapon.reserve == 48, "One physical click consumes one round")
	_expect(world.get_node("Target").hit_count == 1 and hits == 1, "Crosshair hits target before recoil is applied")
	_expect(world.get_node("Target").total_damage == weapon.damage, "Configured damage reaches the test target")
	_expect(world.get_node("HUD/HitMarker").visible, "Confirmed target hit has subtle HUD feedback")
	var hip_kick: float = shot_pitch
	_expect(hip_kick > 0.0 and hip_kick <= deg_to_rad(weapon.recoil_degrees + 0.01), "Hip recoil is immediate and restrained")
	var count: int = shots
	await _click()
	_expect(shots == count and weapon.magazine == 11, "Cooldown rejects rapid clicks without consuming ammo")
	await _frames(20)
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(30)
	_expect(shots == count + 1, "Holding fire does not turn semi-auto into automatic fire")
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(40)
	_expect(absf(player.camera.rotation.x) < 0.0005 and is_zero_approx(player.head.rotation.x), "Recoil recovers without changing mouse aim")
	_expect(not world.get_node("HUD/HitMarker").visible and not weapon.muzzle_flash.visible, "Short shot feedback expires")
	var total: int = weapon.magazine + weapon.reserve
	await _reload_key()
	_expect(weapon.is_reloading and world.get_node("HUD/WeaponStatus").text == "Nachladen …", "Reload begins with compact feedback")
	count = shots
	await _click()
	_expect(shots == count and weapon.magazine == 10, "Reload blocks firing and does not transfer ammo early")
	await _frames(20)
	await _reload_key()
	await _frames(65)
	_expect(not weapon.is_reloading and weapon.magazine == 12 and weapon.reserve == 46, "Repeated R does not restart reload; only missing rounds are transferred")
	_expect(weapon.magazine + weapon.reserve == total, "Reload conserves total ammunition")
	_expect(world.get_node("HUD/Ammo").text == "12 / 46" and world.get_node("HUD/WeaponStatus").text == "", "HUD follows reload completion")
	_button(MOUSE_BUTTON_RIGHT, true)
	await _frames(15)
	_expect(weapon.is_aiming and player.is_aiming and absf(player.camera.fov - weapon.ads_fov) < 0.5, "ADS responds and reaches configured FOV")
	var previous_yaw: float = player.rotation.y
	var expected_turn: float = 10.0 * player.mouse_sensitivity * tan(deg_to_rad(player.camera.fov * 0.5)) / tan(deg_to_rad(player.field_of_view * 0.5))
	player.apply_mouse_look(Vector2(10.0, 0.0))
	_expect(absf(player.rotation.y - previous_yaw + expected_turn) < 0.00001, "ADS sensitivity follows FOV without smoothing mouse input")
	player.rotation.y = previous_yaw
	Input.action_press("move_back")
	Input.action_press("sprint")
	await _frames(15)
	_expect(Vector2(player.velocity.x, player.velocity.z).length() <= player.walk_speed * player.aim_speed_multiplier + 0.01, "ADS overrides sprint and uses controlled movement speed")
	Input.action_press("crouch")
	await _frames(10)
	_expect(player.is_crouching and Vector2(player.velocity.x, player.velocity.z).length() <= player.crouch_speed * player.aim_speed_multiplier + 0.01, "ADS integrates with crouch")
	_release_movement()
	await _frames(10)
	await _click()
	_expect(shot_pitch < hip_kick, "ADS reduces shot recoil")
	await _reload_key()
	_expect(weapon.is_reloading and not weapon.is_aiming and not player.is_aiming, "Reload exits ADS without leaving movement aim state stuck")
	var before_cancel: int = weapon.magazine
	var reserve_before: int = weapon.reserve
	player._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _frames(90)
	_expect(not weapon.is_reloading and weapon.magazine == before_cancel and weapon.reserve == reserve_before, "Focus loss cancels reload without granting ammunition")
	_expect(not weapon.is_aiming and is_equal_approx(player.camera.fov, player.field_of_view), "Focus loss restores hip camera")
	count = shots
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(20)
	_expect(player.has_mouse_capture and shots == count, "Recapture click and holding it never fire")
	_expect(not weapon.is_aiming, "Held RMB does not silently restore ADS after focus loss")
	_button(MOUSE_BUTTON_LEFT, false)
	_button(MOUSE_BUTTON_RIGHT, false)
	await _frames(3)
	await _click()
	_expect(shots == count + 1, "Fresh click after recapture fires normally")
	await _place(Vector3(-1.4, 0.02, -6.0), PI)
	count = world.get_node("Target").hit_count
	var hit_count_before: int = hits
	await _click()
	_expect(world.get_node("Target").hit_count == count and hits == hit_count_before, "Wall blocks shots and does not give target-hit confirmation")
	await _place(Vector3(-1.4, 0.02, 0.0))
	var previous_range: float = weapon.shot_range
	weapon.shot_range = 1.0
	count = world.get_node("Target").hit_count
	await _click()
	_expect(world.get_node("Target").hit_count == count, "Hitscan obeys configured range")
	weapon.shot_range = previous_range
	await _frames(15)
	# Put an existing prop directly on the shot line; no extra test-level objects.
	var prop := world.get_node("CrateA") as RigidBody3D
	prop.freeze = true
	prop.position = Vector3(-1.4, 1.65, -2.0)
	prop.linear_velocity = Vector3.ZERO
	await _frames(2)
	prop.freeze = false
	count = world.get_node("Target").hit_count
	await _click()
	_expect(prop.linear_velocity.z < -0.5, "Hits apply physical impulses to a rigid body")
	_expect(world.get_node("Target").hit_count == count, "First collider prevents shooting through a prop")
	await _place(Vector3(0.0, 0.02, 3.0))
	# Recoil must respect the camera's vertical limit, including near straight up.
	player.apply_mouse_look(Vector2(0.0, -100000.0))
	await _click()
	_expect(player.head.rotation.x + player.camera.rotation.x <= deg_to_rad(89.0) + 0.0001, "Recoil cannot push the view beyond the vertical look limit")
	player.apply_mouse_look(Vector2(0.0, deg_to_rad(89.0) / player.mouse_sensitivity))
	await _place(Vector3(0.0, 0.02, 0.0))
	# E remains independent from R, aim and the firing actions.
	player.apply_mouse_look(Vector2(0.0, 0.16 / player.mouse_sensitivity))
	Input.action_press("interact")
	await _frames(1)
	Input.action_release("interact")
	_expect(world.get_node("Switch").active, "E interaction still works with the firearm equipped")
	player.apply_mouse_look(Vector2(0.0, -0.16 / player.mouse_sensitivity))
	await _place(Vector3(0.0, 0.02, 3.0))
	# Consume the remaining real magazine, then test empty and partial reserve states.
	while weapon.magazine > 0:
		await _frames(13)
		await _click()
	count = shots
	await _frames(15)
	await _click()
	_expect(weapon.magazine == 0 and shots == count and world.get_node("HUD/WeaponStatus").text == "Leer · R", "Empty trigger does not shoot or underflow ammo")
	# A small reserve is a deliberate fixture for the final partial reload edge case.
	weapon.reserve = 3
	await _reload_key()
	await _frames(85)
	_expect(weapon.magazine == 3 and weapon.reserve == 0, "Partial reserve reload transfers exactly the available rounds")
	await _reload_key()
	_expect(not weapon.is_reloading, "No-reserve reload is rejected")
	for index: int in range(3):
		await _frames(13)
		await _click()
	await _frames(15)
	await _click()
	_expect(weapon.magazine == 0 and weapon.reserve == 0 and world.get_node("HUD/WeaponStatus").text == "Keine Munition", "Fully depleted weapon remains in a valid state")
	_expect(not player.camera.is_ancestor_of(player.body_shape), "View recoil cannot rotate the player collision capsule")
	print("Weapon checks: %d passed, %d failed" % [checks - failures, failures])
	_release_movement()
	_button(MOUSE_BUTTON_LEFT, false)
	_button(MOUSE_BUTTON_RIGHT, false)
	world.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _on_fired() -> void:
	shots += 1
	shot_pitch = player.camera.rotation.x

func _button(button: MouseButton, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = Vector2(640, 360)
	Input.parse_input_event(event)

func _click() -> void:
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(1)
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(1)

func _reload_key() -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_R
	event.pressed = true
	Input.parse_input_event(event)
	await _frames(1)
	event = InputEventKey.new()
	event.physical_keycode = KEY_R
	Input.parse_input_event(event)
	await _frames(1)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _place(position: Vector3, yaw: float = 0.0) -> void:
	player.set_mouse_capture(false)
	player.position = position
	player.rotation.y = yaw
	player.velocity = Vector3.ZERO
	player.set_mouse_capture(true)
	await _frames(15)

func _release_movement() -> void:
	for action: String in ["move_back", "sprint", "crouch"]:
		Input.action_release(action)

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

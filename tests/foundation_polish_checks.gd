extends SceneTree
var checks: int = 0
var failures: int = 0
var shots: int = 0
var game: Node3D
var actor: FPSController
var gun: TestFirearm
var view: Node3D

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://scenes/startup.tscn").instantiate()
	game.show_arms = true
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	view = gun.get_node("Visuals/ModelMount/MakarovViewmodel")
	gun.fired.connect(func() -> void: shots += 1)
	await _frames(20)
	_expect(ProjectSettings.get_setting("rendering/anti_aliasing/quality/msaa_3d") == 2, "Forward+ uses 4x MSAA")
	_expect(not InputMap.has_action("quit_game") and InputMap.action_get_events("holster")[0].physical_keycode == KEY_X, "X holsters; Q has no quit binding")
	_key(KEY_Q)
	await _frames(1)
	_expect(not game.is_queued_for_deletion(), "Q leaves gameplay running")
	Input.action_press("crouch")
	await _frames(2)
	_expect(actor.is_crouching and is_equal_approx((actor.body_shape.shape as CapsuleShape3D).height, actor.crouching_height), "Crouch collision changes immediately")
	_expect(actor.head.position.y > actor.crouching_eye_height and actor.head.position.y < actor.standing_eye_height, "Crouch eye interpolates without changing mouse rotation")
	await _frames(25)
	_expect(absf(actor.head.position.y - actor.crouching_eye_height) < 0.002, "Crouching eye settles promptly")
	Input.action_release("crouch")
	await _frames(2)
	_expect(not actor.is_crouching and actor.head.position.y > actor.crouching_eye_height and actor.head.position.y < actor.standing_eye_height, "Standing collision and visual interpolation remain separate")
	await _frames(25)
	_expect(absf(actor.head.position.y - actor.standing_eye_height) < 0.002, "Standing eye settles promptly")
	var skeleton: Skeleton3D = view.skeleton
	var hand: int = skeleton.find_bone("hand.R")
	var grip: Transform3D = (skeleton.global_transform * skeleton.get_bone_global_pose(hand)).affine_inverse() * view.pistol.global_transform
	var ready_pose: Transform3D = skeleton.get_bone_pose(hand)
	await _capture("polish_ready")
	_button(MOUSE_BUTTON_RIGHT, true)
	await _frames(25)
	_expect(gun.is_aiming and not game.get_node("HUD/Crosshair").visible, "ADS uses model sights without a duplicate crosshair")
	await _capture("polish_ads")
	gun.magazine = 10
	_key(KEY_R)
	await _frames(2)
	_expect(gun.is_reloading, "Partial magazine starts normal reload")
	var total: int = gun.magazine + gun.reserve
	_key(KEY_X)
	await _frames(2)
	_expect(gun.is_holstered and not gun.is_reloading and not gun.is_aiming and not actor.is_aiming, "Holster cancels reload and ADS immediately")
	_expect(gun.holster_amount > 0.0 and gun.holster_amount < 1.0, "Holster presentation transitions over time")
	var moving_grip: Transform3D = (skeleton.global_transform * skeleton.get_bone_global_pose(hand)).affine_inverse() * view.pistol.global_transform
	_expect(moving_grip.is_equal_approx(grip), "Weapon stays attached during the blended holster pose")
	await _capture("polish_lowering")
	_key(KEY_X)
	_key(KEY_X, true)
	_button(MOUSE_BUTTON_LEFT, true)
	_key(KEY_R)
	await _frames(25)
	_expect(gun.is_holstered and not gun.is_weapon_ready(), "Repeated inputs during transition cannot reverse or ready the weapon")
	_expect(shots == 0 and not gun.is_reloading and gun.magazine + gun.reserve == total, "Holstered weapon blocks fire/reload without changing ammunition")
	_expect(not view.pistol.visible and view.visible and view.get_node("ArmsOrientation").visible, "Holster hides pistol while keeping the arms instance visible")
	_expect(not game.get_node("HUD/Ammo").visible and not game.get_node("HUD/Crosshair").visible, "Holstered HUD hides weapon-only information")
	_expect(not skeleton.get_bone_pose(hand).is_equal_approx(ready_pose), "Holstered arms use the relaxed pose rather than an empty pistol grip")
	await _capture("polish_holstered")
	actor.position = Vector3(0.0, 0.02, 0.0)
	actor.apply_mouse_look(Vector2(0.0, 0.16 / actor.mouse_sensitivity))
	await _frames(3)
	_key(KEY_E)
	await _frames(2)
	_expect(game.get_node("Switch").active, "Holstered arms leave E interaction usable")
	actor.apply_mouse_look(Vector2(0.0, -0.16 / actor.mouse_sensitivity))
	_key(KEY_X)
	await _frames(25)
	_expect(gun.is_weapon_ready() and view.pistol.visible and shots == 0 and not gun.is_aiming, "Draw restores the weapon; held mouse buttons cannot shoot or aim")
	_button(MOUSE_BUTTON_LEFT, false)
	_button(MOUSE_BUTTON_RIGHT, false)
	for cycle: int in range(3):
		_key(KEY_X)
		await _frames(20)
		_key(KEY_X)
		await _frames(20)
	_expect(skeleton.get_bone_pose(hand).is_equal_approx(ready_pose) and gun.magazine + gun.reserve == total,
		"Repeated holster/draw cycles preserve the corrected pose and ammunition")
	await _frames(3)
	_button(MOUSE_BUTTON_RIGHT, true)
	await _frames(25)
	var sight: Node3D = view.pistol.get_node("SightLine")
	_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, "ADS remains centered after holster/draw pose restoration")
	_button(MOUSE_BUTTON_RIGHT, false)
	await _frames(25)
	gun._cooldown = 0.045
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(8)
	_expect(shots == 1 and gun.magazine == 9, "A held click in the final cooldown window fires exactly once")
	await _frames(20)
	_expect(shots == 1, "Buffer never turns held semi-auto into automatic fire")
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(2)
	gun._cooldown = 0.055
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(1)
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(10)
	_expect(shots == 1, "Releasing a buffered click prevents a delayed shot")
	gun._cooldown = 0.15
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(20)
	_expect(shots == 1, "Clicks outside the short buffer window never fire later")
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(2)
	gun._cooldown = 0.055
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(1)
	_key(KEY_R)
	await _frames(10)
	_expect(shots == 1 and gun.is_reloading, "Reload clears a buffered shot")
	actor.set_mouse_capture(false)
	actor.set_mouse_capture(true)
	_button(MOUSE_BUTTON_LEFT, false)
	await _frames(2)
	gun._cooldown = 0.055
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(1)
	_key(KEY_X)
	await _frames(20)
	_expect(shots == 1 and gun.is_holstered, "Holster clears a buffered shot")
	_button(MOUSE_BUTTON_LEFT, false)
	view.set_imported_visible(false)
	await _frames(2)
	_expect(not gun.get_node("Visuals/ModelMount/Placeholder").visible, "Fallback stays hidden while holstered")
	_key(KEY_X)
	await _frames(25)
	_expect(gun.get_node("Visuals/ModelMount/Placeholder").visible and gun.is_weapon_ready(), "Fallback can be drawn normally")
	view.set_imported_visible(true)
	await _frames(2)
	gun._cooldown = 0.055
	_button(MOUSE_BUTTON_LEFT, true)
	await _frames(1)
	actor._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await _frames(12)
	_expect(shots == 1 and not gun.is_aiming and not gun.is_reloading, "Focus loss clears the buffer and weapon actions")
	_button(MOUSE_BUTTON_LEFT, false)
	_key(KEY_X)
	await _frames(2)
	_expect(not gun.is_holstered, "Uncaptured X cannot change holster state")
	game.queue_free()
	await process_frame
	print("Foundation polish checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _button(button: MouseButton, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)

func _key(code: Key, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.physical_keycode = code
	Input.parse_input_event(event)

func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/weapon_captures")
	_expect(image != null and image.save_png("res://.godot/checks/weapon_captures/%s.png" % label) == OK, "Rendered " + label)

func _expect(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

extends SceneTree
## Motion transitions tested on the actual F5 scene, without changing hit registration.
var checks: int = 0
var failures: int = 0
var game: Node3D
var actor: FPSController
var gun: TestFirearm
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	game = load("res://scenes/startup.tscn").instantiate()
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	await _frames(20)
	for index: int in range(8):
		_key(KEY_1 + index)
		await _frames(25)
		var view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
		var label: String = gun.test_profile.display_name + ": "
		actor.position = Vector3(0, 0.02, 13)
		actor.rotation = Vector3.ZERO
		actor.velocity = Vector3.ZERO
		await _frames(8)
		Input.action_press("move_forward")
		Input.action_press("sprint")
		await _frames(25)
		_expect(actor.is_sprinting and view.position.length() > 0.05 and view.rotation.length() > 0.15, label + "sprint has a visible carry position and angle")
		_expect(_near_clear(view.model), label + "carry geometry clears the near plane")
		_expect(is_zero_approx(actor.head.rotation.x) and is_zero_approx(actor.camera.rotation.z), label + "carry never tilts mouse aim or camera roll")
		_expect(gun.get_node("Visuals/Muzzle").global_transform.is_equal_approx(view.model.get_node("Muzzle").global_transform), label + "muzzle stays on the moving model")
		await _capture("sprint_%d" % index)
		Input.action_press("aim")
		await _frames(30)
		_expect(view._sprint_blend < 0.01 and actor.is_aiming and not actor.is_sprinting, label + "ADS wins over sprint without an action delay")
		var sight: Node3D = view.model.get_node("SightLine")
		_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, label + "sprint-to-ADS returns the sight to screen center")
		await _capture("ads_%d" % index)
		Input.action_release("aim")
		Input.action_release("sprint")
		Input.action_release("move_forward")
		await _frames(25)
		_expect(view.position.length() < 0.002 and _near_clear(view.model), label + "stopping returns to calibrated hip placement")
		var ammo: int = gun.magazine
		_button(true)
		await _frames(2)
		_button(false)
		await _frames(2)
		_expect(gun.magazine == ammo - 1 and gun._kick <= gun.visual_kick, label + "fresh shot retains responsive ammo and bounded model kick")
		# Inspect the final visible part of a holster path, not an implementation offset.
		var previous: float = gun.holster_amount
		gun.holster_amount = 0.96
		view._update_transform()
		var muzzle_screen: Vector2 = actor.camera.unproject_position(view.model.get_node("Muzzle").global_position)
		_expect(muzzle_screen.y > root.get_visible_rect().size.y, label + "barrel leaves the screen before the model is hidden")
		gun.holster_amount = previous
		view._update_transform()
		_key(KEY_X)
		await _frames(20)
		_expect(gun.is_holstered and not view.model.visible, label + "holster reaches the hidden state")
		_key(KEY_X)
		await _frames(20)
		_expect(gun.is_weapon_ready() and view.model.visible and gun.magazine == ammo - 1, label + "draw returns ready with unchanged ammunition")
	var fallback_view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
	fallback_view.set_imported_visible(false)
	var placeholder: Node3D = gun.get_node("Visuals/ModelMount/Placeholder")
	var flash_mount: Node3D = gun.get_node("Visuals/Muzzle")
	var binding: Transform3D = placeholder.global_transform.affine_inverse() * flash_mount.global_transform
	actor.position = Vector3(0, 0.02, 13)
	actor.velocity = Vector3.ZERO
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await _frames(25)
	_expect((placeholder.global_transform.affine_inverse() * flash_mount.global_transform).is_equal_approx(binding), "Placeholder muzzle stays attached during sprint carrying")
	fallback_view.set_imported_visible(true)
	actor.position = Vector3(19, 0.02, -1)
	actor.rotation.y = -PI * 0.5
	actor.velocity = Vector3.ZERO
	await _frames(40)
	_expect(Vector2(actor.velocity.x, actor.velocity.z).length() < 0.1 and fallback_view._sprint_blend < 0.01, "Blocked sprint returns ready rather than carrying while stationary")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	actor.position = Vector3(0, 0.02, 13)
	actor.rotation.y = 0
	actor.velocity = Vector3.ZERO
	# Zoom should move continuously when a weapon change interrupts ADS.
	_key(KEY_3)
	await _frames(25)
	Input.action_press("aim")
	await _frames(40)
	var zoom: float = actor.camera.fov
	_key(KEY_5)
	await _frames(2)
	_expect(actor.camera.fov > zoom and actor.camera.fov < actor.field_of_view - 1.0, "ADS switch eases FOV back rather than snapping to hip FOV (%.2f -> %.2f)" % [zoom, actor.camera.fov])
	await _frames(30)
	_expect(not gun.is_aiming and absf(actor.camera.fov - actor.field_of_view) < 0.1, "Switch settles at hip FOV without held-button ADS")
	Input.action_release("aim")
	actor.position = Vector3(0, 0.02, 13)
	actor.velocity = Vector3.ZERO
	Input.action_press("sprint")
	Input.action_press("move_forward")
	await _frames(25)
	var view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
	_button(true)
	await _frames(20)
	_expect(view._sprint_blend < 0.02 and gun._automatic_firing, "Automatic burst keeps the ready pose between shots")
	_button(false)
	var held_ready: bool = true
	var observed_hold: bool = false
	for frame: int in range(30):
		if view._ready_hold <= 0.04:
			break
		observed_hold = true
		held_ready = held_ready and view._sprint_blend < 0.05
		await process_frame
	_expect(observed_hold and held_ready, "Shot-owned hold prevents carry pumping throughout its remaining duration")
	await _capture("burst_ready")
	await _frames(20)
	_expect(view._sprint_blend > 0.5, "Continued sprint smoothly resumes carrying after recovery")
	_key(KEY_2)
	await _frames(4)
	_expect(not gun.is_weapon_ready() and view._sprint_blend > 0.3, "Drawing while sprinting prepares carry before the firearm becomes ready")
	await _capture("draw_into_sprint")
	await _frames(20)
	var ammo: Vector2i = Vector2i(gun.magazine, gun.reserve)
	_key(KEY_R)
	await _frames(20)
	_expect(gun.is_reloading and view._sprint_blend < 0.02, "Reload overrides sprint carrying with its authoritative timing")
	await _capture("reload_from_sprint")
	_key(KEY_X)
	await _frames(20)
	_expect(not gun.is_reloading and Vector2i(gun.magazine, gun.reserve) == ammo, "Holstering during the blended reload cannot transfer ammunition")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	_key(KEY_X)
	await _frames(25)
	actor.set_mouse_capture(false)
	_expect(actor.camera.fov == actor.field_of_view and not gun._automatic_firing, "Focus loss still resets view and input immediately")
	game.queue_free()
	await process_frame
	print("Weapon motion checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
func _near_clear(model: WeaponAsset) -> bool:
	for mesh: MeshInstance3D in model.parts.values():
		if mesh.visible:
			var bounds: AABB = actor.camera.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
			if bounds.end.z >= -actor.camera.near:
				return false
	return true
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
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/weapon_motion")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/weapon_motion/%s.png" % label) == OK, "Rendered " + label)
func _expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

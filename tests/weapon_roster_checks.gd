extends SceneTree
var checks: int = 0
var failures: int = 0
var shots: int = 0
var game: Node3D
var gun: TestFirearm
var actor: FPSController

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	game = load("res://scenes/fps_test_fallback.tscn").instantiate()
	game.test_weapon = 0
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	gun.fired.connect(func() -> void: shots += 1)
	await _frames(15)
	_expect(gun.weapon_profiles.size() == 8, "Eight profiles share one authoritative firearm")
	for index: int in range(8):
		_key(KEY_1 + index)
		await _frames(25)
		var view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
		var model: WeaponAsset = view.model
		var name: String = gun.test_profile.display_name
		_expect(gun.active_weapon == index and game.get_node("HUD/WeaponName").text == name, name + ": number key selects profile and HUD name")
		_expect(view.get_child_count() == 1 and gun.is_weapon_ready() and model.visible, name + ": one active model after draw")
		var valid: bool = true
		var geometry := AABB()
		var first: bool = true
		for mesh: MeshInstance3D in model.parts.values():
			for surface: int in range(mesh.mesh.get_surface_count()):
				var material: StandardMaterial3D = mesh.get_active_material(surface)
				valid = valid and material != null and material.albedo_texture != null
			if mesh.visible:
				var bounds: AABB = actor.camera.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
				valid = valid and bounds.end.z < -actor.camera.near
				var local_bounds: AABB = model.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
				geometry = local_bounds if first else geometry.merge(local_bounds)
				first = false
		_expect(valid, name + ": visible parts retain textures and clear the near plane")
		_expect(geometry.size.z > 0.15 and geometry.size.z < 1.05, name + ": coherent physical model length")
		await _capture("hip_%d" % index)
		Input.action_press("aim")
		await _frames(30)
		_expect(_near_clear(model), name + ": ADS geometry clears the camera near plane")
		var sight: Node3D = model.get_node("SightLine")
		_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, name + ": marker-derived ADS is centered")
		_expect((-model.global_basis.z).dot(-actor.camera.global_basis.z) > 0.999, name + ": ADS barrel matches camera forward")
		_expect(gun.get_node("Visuals/Muzzle").global_transform.is_equal_approx(model.get_node("Muzzle").global_transform), name + ": muzzle stays on the model")
		await _capture("ads_%d" % index)
		Input.action_release("aim")
		await _frames(15)
		actor.position = Vector3(-1.4, 0.02, 0.0)
		await _frames(3)
		var hits_before: int = game.get_node("Target").hit_count
		var before: int = shots
		_button(true)
		await _frames(2)
		_button(false)
		await _frames(2)
		_expect(shots == before + 1 and gun.magazine == gun.magazine_capacity - 1, name + ": one fresh press consumes exactly one round")
		_expect(game.get_node("Target").hit_count == hits_before + 1, name + ": camera hitscan still reaches the actual target")
		_key(KEY_R)
		await _frames(2)
		_expect(gun.is_reloading, name + ": reload starts with its own timing")
		_key(KEY_X)
		await _frames(20)
		_expect(gun.is_holstered and not gun.is_reloading and gun.magazine == gun.magazine_capacity - 1, name + ": holster safely cancels reload without ammo transfer")
	_key(KEY_X)
	await _frames(20)
	var reserve_before: int = gun.reserve
	_key(KEY_R)
	await _frames(160)
	_expect(not gun.is_reloading and gun.magazine == gun.magazine_capacity and gun.reserve == reserve_before - 1, "STG44 completes reload with conserved ammunition")
	for index: int in range(8):
		_key(KEY_1 + index)
		await _frames(20)
		var profile: TestWeaponProfile = gun.test_profile
		_expect(gun.magazine == profile.magazine_capacity - (0 if index == 7 else 1) and gun.reserve == profile.reserve - (1 if index == 7 else 0), profile.display_name + ": ammunition survives a full roster round trip")
	# Persistence and transitions exercise real input and physics, not only profile data.
	_key(KEY_1)
	await _frames(25)
	_button(true)
	await _frames(2)
	_button(false)
	await _frames(2)
	var makarov: int = gun.magazine
	var makarov_reserve: int = gun.reserve
	_key(KEY_R)
	await _frames(10)
	_key(KEY_5)
	await _frames(25)
	_expect(gun.active_weapon == 4 and not gun.is_reloading, "Switch cancels reload before any ammo transfer")
	_button(true)
	await _frames(2)
	_button(false)
	await _frames(2)
	var m4: int = gun.magazine
	_key(KEY_1)
	await _frames(25)
	_expect(gun.magazine == makarov and gun.reserve == makarov_reserve, "Returning restores the pistol's exact ammunition")
	_key(KEY_5)
	await _frames(25)
	_expect(gun.magazine == m4, "M4 ammunition persists independently")
	Input.action_press("aim")
	await _frames(15)
	_button(true)
	await _frames(2)
	var count: int = shots
	_key(KEY_6)
	_key(KEY_7)
	_key(KEY_8)
	await _frames(25)
	_expect(gun.active_weapon == 7 and shots == count and not gun.is_aiming and not actor.is_aiming, "Rapid switching chooses the last request without held-button shots or ADS")
	_button(false)
	Input.action_release("aim")
	await _frames(3)
	_key(KEY_X)
	await _frames(20)
	_key(KEY_2)
	await _frames(25)
	_expect(gun.active_weapon == 1 and gun.is_weapon_ready() and not gun.is_holstered, "Switch from holstered state draws the selected weapon")
	actor.set_mouse_capture(false)
	_key(KEY_3)
	await _frames(2)
	_expect(gun.active_weapon == 1, "Uncaptured number keys cannot switch weapons")
	actor.set_mouse_capture(true)
	await _frames(3)
	_key(KEY_3)
	actor.set_mouse_capture(false)
	await _frames(2)
	_expect(gun.active_weapon == 1, "Focus loss clears a queued switch")
	actor.set_mouse_capture(true)
	await _frames(3)
	_key(KEY_4)
	await _frames(25)
	var presentation: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
	presentation.set_imported_visible(false)
	_key(KEY_5)
	await _frames(25)
	_expect(gun.get_node("Visuals/ModelMount/Placeholder").visible and not presentation.model.visible, "Placeholder fallback remains active across switches")
	presentation.set_imported_visible(true)
	_key(KEY_1)
	await _frames(25)
	_button(true)
	await _frames(2)
	_button(false)
	await _frames(1)
	var cooldown: float = gun._cooldown
	var last_magazine: int = gun.magazine
	_key(KEY_5)
	await _frames(1)
	_key(KEY_1)
	await _frames(1)
	_expect(cooldown > 0.0 and gun._cooldown > 0.0 and gun._cooldown <= cooldown and gun.magazine == last_magazine, "Rapid round trip preserves the running shot cooldown and exact ammunition")
	count = shots
	_button(true)
	await _frames(8)
	_button(false)
	_expect(shots == count, "Switch draw gate rejects clicks instead of buffering an unintended shot")
	game.queue_free()
	await process_frame
	# Optional arms must also work when the first selected weapon was a rifle.
	game = load("res://scenes/fps_test_fallback.tscn").instantiate()
	game.show_arms = true
	game.test_weapon = 1
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	await _frames(10)
	_key(KEY_1)
	await _frames(25)
	var arms: Node3D = gun.get_node("Visuals/ModelMount/MakarovViewmodel")
	_expect(arms.visible and gun.show_arms and gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel").model == null, "Switching from a rifle restores the optional Makarov arms")
	await _capture("arms_restored")
	_key(KEY_8)
	await _frames(25)
	_expect(not arms.visible and not gun.show_arms, "Switching away disables the optional arms again")
	game.queue_free()
	await process_frame
	game = load("res://scenes/fps_test_fallback.tscn").instantiate()
	game.show_arms = true
	game.use_imported_visuals = false
	game.test_weapon = 4
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	await _frames(10)
	_expect(gun.get_node("Visuals/ModelMount/Placeholder").visible, "Startup fallback works with a rifle and optional arms enabled")
	_key(KEY_1)
	await _frames(25)
	_expect(gun.get_node("Visuals/ModelMount/Placeholder").visible and not gun.get_node("Visuals/ModelMount/MakarovViewmodel").visible and gun.get_node("Visuals/Muzzle").transform.is_equal_approx(gun.placeholder_muzzle), "Optional-arm pistol fallback restores the original primitive muzzle after a rifle")
	game.queue_free()
	await process_frame
	print("Weapon roster checks: %d passed, %d failed" % [checks - failures, failures])
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
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/roster")
	var image: Image = root.get_texture().get_image()
	_expect(image != null and image.save_png("res://.godot/checks/roster/%s.png" % label) == OK, "Rendered " + label)

func _expect(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

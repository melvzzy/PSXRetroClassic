extends SceneTree
var checks: int = 0
var failures: int = 0
var shots: int = 0
var _label: String

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for index: int in range(4):
		var game: Node3D = load("res://scenes/fps_test_fallback.tscn").instantiate()
		game.test_weapon = index
		root.add_child(game)
		await _frames(20)
		var actor: FPSController = game.get_node("Player")
		var gun: TestFirearm = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
		var view: Node3D = gun.get_node("Visuals/ModelMount/WeaponOnlyViewmodel")
		var arms: Node3D = gun.get_node("Visuals/ModelMount/MakarovViewmodel")
		var profile: TestWeaponProfile = gun.test_profile
		var model: WeaponAsset = view.model
		_label = profile.display_name
		gun.fired.connect(func() -> void: shots += 1)
		_expect(not arms.visible and arms.process_mode == Node.PROCESS_MODE_DISABLED and not arms.find_child("AnimationPlayer", true, false).active, "Arms hidden and skeletal animation disabled")
		_expect(gun.magazine == profile.magazine_capacity and gun.reserve == profile.reserve, "Selected profile initializes authoritative ammunition")
		_expect(model.scene_file_path == profile.model.resource_path, "Only the preselected weapon model is active")
		var materials: bool = true
		for mesh: MeshInstance3D in model.parts.values():
			materials = materials and mesh.get_active_material(0).albedo_texture == model.albedo
		_expect(materials, "Original textures resolve on all parts")
		_expect(_near_clear(model, actor.camera), "Hip geometry clears the camera near plane")
		var independent: Transform3D = model.global_transform
		arms.get_node("ArmsOrientation").position += Vector3(2.0, 1.0, 3.0)
		await _frames(2)
		_expect(model.global_transform.is_equal_approx(independent), "Inactive arm transforms cannot move the selected weapon")
		await _capture("hip_%d" % index)
		Input.action_press("aim")
		await _frames(35)
		var sight: Node3D = model.get_node("SightLine")
		_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, "Sight marker aligns with camera center in ADS")
		_expect((-model.global_basis.z).dot(-actor.camera.global_basis.z) > 0.999, "Barrel and camera hitscan face the same direction")
		_expect(gun.get_node("Visuals/Muzzle").global_transform.is_equal_approx(model.get_node("Muzzle").global_transform), "Muzzle follows actual model marker")
		_expect(_near_clear(model, actor.camera), "ADS geometry clears the camera near plane")
		if index > 0:
			var front: MeshInstance3D = model.get_part("front sight")
			var closest: float = INF
			for surface: int in range(front.mesh.get_surface_count()):
				for vertex: Vector3 in front.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
					var point: Vector3 = model.global_transform.affine_inverse() * front.global_transform * vertex
					if absf(point.x) < 0.001 and absf(point.y - sight.position.y) < 0.001:
						closest = minf(closest, actor.camera.unproject_position(front.global_transform * vertex).distance_to(root.get_visible_rect().size * 0.5))
			_expect(closest < 2.0, "Actual front sight geometry reaches the screen-center aim line")
		await _capture("ads_%d" % index)
		Input.action_release("aim")
		await _frames(25)
		actor.position = Vector3(-1.4, 0.02, 0.0)
		await _frames(3)
		var hits_before: int = game.get_node("Target").hit_count
		var before: int = shots
		_button(true)
		await _frames(2)
		_button(false)
		_expect(shots == before + 1 and gun.magazine == profile.magazine_capacity - 1, "Physical click fires once and consumes one round")
		_expect(game.get_node("Target").hit_count == hits_before + 1, "Camera-based hitscan reaches the actual target before recoil")
		await _capture("firing_%d" % index)
		await _frames(25)
		_button(true)
		await _frames(30)
		_button(false)
		_expect(shots == before + 2, "Held trigger remains semi-automatic")
		var total: int = gun.magazine + gun.reserve
		var magazine: Node3D = model.get_part("Magazine-Full" if index == 0 else "magazine")
		var seated: Transform3D = magazine.transform
		_key(KEY_R)
		await _frames(20)
		_expect(gun.is_reloading and not gun.is_aiming and magazine.transform.is_equal_approx(seated), "Reload uses existing state and keeps the unsupported magazine seated")
		await _capture("reload_%d" % index)
		await _frames(150)
		_expect(not gun.is_reloading and gun.magazine == profile.magazine_capacity and gun.magazine + gun.reserve == total, "Reload completes once and conserves ammunition")
		_key(KEY_X)
		await _frames(20)
		_expect(gun.is_holstered and not model.visible and not arms.visible, "Holstered mode contains neither weapon nor arms")
		_button(true)
		_key(KEY_R)
		await _frames(3)
		_expect(shots == before + 2 and not gun.is_reloading, "Holster blocks fire and reload")
		await _capture("holstered_%d" % index)
		_key(KEY_X)
		await _frames(25)
		_expect(gun.is_weapon_ready() and model.visible and shots == before + 2, "Draw restores the selected model without firing held input")
		_button(false)
		var imported_muzzle: Transform3D = gun.get_node("Visuals/Muzzle").transform
		view.set_imported_visible(false)
		_expect(gun.get_node("Visuals/ModelMount/Placeholder").visible and not model.visible, "Original placeholder can replace this model")
		view.set_imported_visible(true)
		_expect(gun.get_node("Visuals/Muzzle").transform.is_equal_approx(imported_muzzle), "Returning from fallback restores the calibrated muzzle")
		actor.set_mouse_capture(false)
		_expect(not gun.is_aiming and not gun.is_reloading, "Focus/capture release clears actions")
		game.queue_free()
		await process_frame
	print("Four weapon checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)

func _near_clear(model: WeaponAsset, camera: Camera3D) -> bool:
	for mesh: MeshInstance3D in model.parts.values():
		if not mesh.visible:
			continue
		var bounds: AABB = camera.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		if bounds.end.z >= -camera.near:
			return false
	return true

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _key(code: Key) -> void:
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
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/four_weapons")
	var image: Image = root.get_texture().get_image()
	_expect(image != null and image.save_png("res://.godot/checks/four_weapons/%s.png" % label) == OK, "Rendered " + label)

func _expect(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: %s: %s" % [_label, label])
	else:
		failures += 1
		push_error("FAIL: %s: %s" % [_label, label])

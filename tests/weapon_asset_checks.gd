extends SceneTree
var checks: int = 0
var failures: int = 0
var shots: int = 0
var captures: bool = false

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	captures = OS.get_cmdline_user_args().has("--capture")
	var preview: Node3D = load("res://scenes/previews/weapon_asset_preview.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var expected_lengths: Array[float] = [0.168, 0.875, 0.894, 0.64, 1.10]
	for index: int in range(5):
		preview.get_node("HUD/Panel/Weapon").select(index)
		preview.select_weapon(index)
		var model: WeaponAsset = preview.model
		var bounds := AABB()
		var first: bool = true
		var materials_valid: bool = true
		for part: MeshInstance3D in model.parts.values():
			var box: AABB = model.global_transform.affine_inverse() * part.global_transform * part.get_aabb()
			if part.visible:
				bounds = box if first else bounds.merge(box)
				first = false
			var material: StandardMaterial3D = part.get_active_material(0)
			materials_valid = materials_valid and material.albedo_texture == model.albedo and material.albedo_texture.get_image().has_mipmaps()
		_expect(materials_valid, "Candidate %d: all parts use the supplied texture with mipmaps" % index)
		_expect(absf(bounds.size.z - expected_lengths[index]) < 0.015, "Candidate %d: corrected meter scale (length %.3f m)" % [index, bounds.size.z])
		_expect(model.find_children("*", "CollisionObject3D", true, false).is_empty(), "Candidate %d: visual import adds no viewmodel collision" % index)
		_expect(preview.get_node("HUD/Panel/PlayClip").disabled, "Candidate %d: no fake fire/reload clip enabled" % index)
		var parts: OptionButton = preview.get_node("HUD/Panel/Part")
		var selected: Node3D = model.get_part(parts.get_item_text(parts.selected))
		var before: Vector3 = selected.global_position
		preview.get_node("HUD/Panel/Offset").value = 0.5
		_expect(absf(selected.global_position.y - before.y - 0.05) < 0.001, "Candidate %d: individual part can be inspected in meters" % index)
		preview.get_node("HUD/Panel/Offset").value = 0.0
		if captures:
			preview.get_node("HUD/Panel/ArmsVisible").button_pressed = false
			preview.get_node("HUD/Panel/Zoom").value = 0.55 if index == 0 else 1.5
			await _capture("candidate_%d" % index)
	preview.queue_free()
	await process_frame
	var game: Node3D = load("res://scenes/startup.tscn").instantiate()
	game.show_arms = true
	root.add_child(game)
	await _frames(15)
	var actor := game.get_node("Player") as FPSController
	var firearm: TestFirearm = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	var view: Node3D = firearm.get_node("Visuals/ModelMount/MakarovViewmodel")
	var pistol: WeaponAsset = view.get_node("Pistol")
	var placeholder: Node3D = firearm.get_node("Visuals/ModelMount/Placeholder")
	_expect(view.visible and not placeholder.visible and firearm.magazine == 12, "Playable scene uses Makarov while preserving existing ammo configuration")
	_expect(not pistol.get_part("Magazine-Empty").visible and pistol.get_part("Magazine-Full").visible, "Alternate magazines do not overlap in-game")
	_expect(view.skeleton.get_bone_count() == 52 and not view.find_child("AnimationPlayer", true, false).is_playing(), "Arms use a stable explicit hold, not an incompatible looping action")
	var skeleton: Skeleton3D = view.skeleton
	var hand_index: int = skeleton.find_bone("hand.R")
	var hand_world: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(hand_index)
	var bind: Transform3D = hand_world.affine_inverse() * pistol.global_transform
	var original_pistol: Transform3D = pistol.global_transform
	var saved_poses: Array[Transform3D] = []
	for bone: int in range(skeleton.get_bone_count()):
		saved_poses.append(skeleton.get_bone_pose(bone))
	var animation: AnimationPlayer = view.find_child("AnimationPlayer", true, false)
	for clip: StringName in animation.get_animation_list():
		var valid: bool = true
		animation.play(clip)
		for fraction: float in [0.0, 0.4, 0.9]:
			animation.seek(animation.get_animation(clip).length * fraction, true)
			animation.pause()
			await _frames(2)
			hand_world = skeleton.global_transform * skeleton.get_bone_global_pose(hand_index)
			var actual: Transform3D = hand_world.affine_inverse() * pistol.global_transform
			var muzzle: Node3D = firearm.get_node("Visuals/Muzzle")
			valid = valid and actual.is_equal_approx(bind) and pistol.global_transform.is_finite()
			valid = valid and absf(pistol.global_basis.determinant() - 1.0) < 0.001
			valid = valid and muzzle.global_transform.is_equal_approx(pistol.get_node("Muzzle").global_transform)
		_expect(valid, "%s: hand-local grip, orientation and muzzle remain valid" % clip)
	for bone: int in range(skeleton.get_bone_count()):
		skeleton.set_bone_pose(bone, saved_poses[bone])
	await _frames(2)
	_expect(pistol.global_transform.is_equal_approx(original_pistol), "Returning to the hold restores the weapon without accumulated drift")
	# Moving the marker must change alignment; a fixed sight-height constant fails.
	var altered_sight: Node3D = pistol.get_node("SightLine")
	var sight_rest: Transform3D = altered_sight.transform
	altered_sight.position += Vector3(0.012, 0.018, 0.0)
	altered_sight.rotation.z = 0.08
	Input.action_press("aim")
	await _frames(35)
	var center: Vector2 = root.get_visible_rect().size * 0.5
	_expect(actor.camera.unproject_position(altered_sight.global_position).distance_to(center) < 2.0,
		"ADS derives alignment from a translated and rotated sight marker")
	_expect(altered_sight.global_basis.is_equal_approx(actor.camera.global_basis), "ADS aligns the marker basis without rotating the camera")
	Input.action_release("aim")
	altered_sight.transform = sight_rest
	await _frames(35)
	_expect(pistol.global_transform.origin.distance_to(original_pistol.origin) < 0.001,
		"Hip placement survives marker changes and ADS transitions")
	var slide: Node3D = pistol.get_part("Slide")
	var magazine: Node3D = pistol.get_part("Magazine-Full")
	var slide_rest: Vector3 = slide.position
	var magazine_rest: Vector3 = magazine.position
	firearm.fired.connect(func() -> void: shots += 1)
	if captures:
		await _capture("game_hip")
	Input.action_press("aim")
	await _frames(25)
	var sight: Node3D = pistol.get_node("SightLine")
	var screen_center: Vector2 = root.get_visible_rect().size * 0.5
	_expect(actor.camera.unproject_position(sight.global_position).distance_to(screen_center) < 2.0, "ADS rear sight reference is centered without changing camera aim")
	_expect((-pistol.global_basis.z).dot(-actor.camera.global_basis.z) > 0.999, "Visible barrel and camera hitscan share the forward axis")
	if captures:
		await _capture("game_ads")
	Input.action_release("aim")
	await _frames(20)
	_button(true)
	await _frames(1)
	_button(false)
	await _frames(1)
	_expect(shots == 1 and firearm.magazine == 11 and slide.position.z > slide_rest.z, "One shot drives one slide motion and consumes exactly one round")
	var reload := InputEventKey.new()
	reload.physical_keycode = KEY_R
	reload.pressed = true
	Input.parse_input_event(reload)
	await _frames(12)
	reload = InputEventKey.new()
	reload.physical_keycode = KEY_R
	Input.parse_input_event(reload)
	_expect(firearm.is_reloading and view._reload_reach > 0.0, "Reload first reaches toward the magazine")
	await _frames(16)
	_expect(firearm.is_reloading and magazine.position.y < magazine_rest.y, "Reload withdrawal synchronizes the support hand and magazine")
	if captures:
		await _capture("game_reload")
	actor.set_mouse_capture(false)
	_expect(not firearm.is_reloading, "Focus/capture release cancels the authoritative reload immediately")
	await _frames(20)
	_expect(magazine.position.is_equal_approx(magazine_rest), "Canceled reload smoothly restores the visual magazine")
	var imported_muzzle: Vector3 = firearm.get_node("Visuals/Muzzle").position
	# A rotated animated muzzle must also restore the placeholder orientation.
	firearm.get_node("Visuals/Muzzle").rotation = Vector3(0.2, -0.3, 0.1)
	view.set_imported_visible(false)
	_expect(placeholder.visible and not view.visible and firearm.get_node("Visuals/Muzzle").transform.is_equal_approx(Transform3D(Basis.IDENTITY, Vector3(0, 0.03, -0.37))), "Original placeholder and muzzle can be restored as a fallback")
	view.set_imported_visible(true)
	_expect(not placeholder.visible and firearm.get_node("Visuals/Muzzle").position.is_equal_approx(imported_muzzle), "Imported model can be restored without rebuilding firearm state")
	_expect(firearm.magazine == 11 and firearm.reserve == 48, "Visual changes and canceled reload never mutate ammunition")
	game.queue_free()
	await process_frame
	print("Weapon asset checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures > 0 else 0)

func _button(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = Vector2(640, 360)
	Input.parse_input_event(event)

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/weapon_captures")
	var image: Image = root.get_texture().get_image()
	_expect(image != null and not image.is_empty() and image.save_png("res://.godot/checks/weapon_captures/%s.png" % name) == OK, "Rendered " + name)

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

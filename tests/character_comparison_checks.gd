extends SceneTree
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var preview: Node3D = load("res://scenes/previews/character_comparison.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var records: Array = []
	for index: int in range(2):
		var model: Node3D = preview.models[index]
		if model == null:
			print("SKIP: Local-only licensed Simple source is not present")
			continue
		var data: Dictionary = preview.audits[index]
		var name: String = "Simple" if index == 0 else "Male"
		_expect(data.bones.size() == (64 if index == 0 else 25), name + ": source skeleton count")
		_expect(data.clips.is_empty(), name + ": no fabricated animation clips")
		_expect(data.invalid_weights == 0, name + ": skin influences resolve to valid skeleton bones")
		var calibrated: Dictionary = preview.inspect_model(model)
		var bounds: AABB = calibrated.bounds
		# inspect_model returns model-space dimensions; the calibrated parent supplies scale.
		var height: float = bounds.size.y * model.get_parent().scale.y
		_expect(absf(height - 1.8) < 0.01, name + ": calibrated 1.8 m visual height")
		var valid: bool = true
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			valid = valid and mesh.skin != null
			for surface: int in range(mesh.mesh.get_surface_count()):
				var material: StandardMaterial3D = mesh.get_active_material(surface)
				valid = valid and material != null
				if material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED:
					valid = valid and material.albedo_texture != null
		_expect(valid, name + ": skinned meshes and opaque textures resolve")
		records.append({"name":name,"source_height":data.bounds.size.y,"triangles":data.triangles,"bones":data.bones,"weighted_bones":data.weighted_bones,"clips":data.clips})
	if preview.models[0] != null:
		_expect(not preview.audits[0].weighted_bones.has("f_ring.01.R"), "Simple ring bones have no direct skin influence; not advertised as complete grip capability")
		var skeleton: Skeleton3D = preview.skeletons[0]
		var bone: int = skeleton.find_bone("f_index.02.R")
		var initial: Quaternion = skeleton.get_bone_pose_rotation(bone)
		preview.set_probe(true)
		_expect(not skeleton.get_bone_pose_rotation(bone).is_equal_approx(initial), "Diagnostic finger probe moves a real Simple joint")
		preview.set_probe(false)
		_expect(skeleton.get_bone_pose_rotation(bone).is_equal_approx(initial), "Probe restores the original imported pose")
	_expect(not preview.audits[1].weighted_bones.has("thumb.01.R"), "Male thumb bones have no direct skin influence")
	for view: int in range(5):
		preview.set_view(view)
		_expect(preview.camera.global_transform.is_finite(), "Inspection camera %d is valid" % view)
		await _capture("view_%d" % view)
	preview.set_probe(true)
	for view: int in [3,4]:
		preview.set_view(view)
		await _capture("probe_%d" % view)
	preview.set_probe(false)
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/character_comparison")
	var report:=FileAccess.open("res://.godot/checks/character_comparison/report.json",FileAccess.WRITE)
	report.store_string(JSON.stringify(records,"  "))
	preview.queue_free()
	await process_frame
	print("Character comparison checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
func _capture(title: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.godot/checks/character_comparison")
	_expect(root.get_texture().get_image().save_png("res://.godot/checks/character_comparison/%s.png" % title) == OK, "Rendered " + title)
func _expect(value: bool, title: String) -> void:
	checks += 1
	if value:
		print("PASS: " + title)
	else:
		failures += 1
		push_error("FAIL: " + title)

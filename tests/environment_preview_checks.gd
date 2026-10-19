extends SceneTree
var checks: int = 0
var failures: int = 0
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var scene: Node3D = load("res://scenes/previews/environment_preview.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	_expect(scene.get_node("Buildings").get_child_count() == 2, "Two independent building candidates")
	_expect(scene.get_node("Roads").get_child_count() == 2, "Two isolated road samples")
	_expect(scene.get_node("Vegetation").get_child_count() == 4, "One coherent summer vegetation family")
	_expect(scene.get_node("IndustrialProps").get_child_count() == 6, "Six practical industrial/prop comparisons")
	_expect(scene.find_children("*", "PhysicsBody3D", true, false).is_empty(), "Inspection models introduce no gameplay collision")
	_expect(is_equal_approx(scene.get_node("ScaleReference_1_8m").mesh.size.y, 1.8), "Explicit human-height scale reference")
	for group: String in ["Buildings", "Roads", "Vegetation", "IndustrialProps"]:
		for holder: Node3D in scene.get_node(group).get_children():
			var meshes: Array[Node] = holder.find_children("*", "MeshInstance3D", true, false)
			var valid: bool = not meshes.is_empty()
			var bounds := AABB()
			var first: bool = true
			for mesh: MeshInstance3D in meshes:
				var box: AABB = holder.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
				bounds = box if first else bounds.merge(box)
				first = false
				valid = valid and mesh.global_transform.is_finite()
				for surface: int in range(mesh.mesh.get_surface_count()):
					var material: StandardMaterial3D = mesh.get_active_material(surface)
					valid = valid and material != null and material.albedo_texture != null
					if group == "Vegetation":
						valid = valid and material.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR and material.cull_mode == BaseMaterial3D.CULL_DISABLED
			_expect(valid, holder.name + ": complete textured geometry and safe alpha settings")
			_expect(absf(bounds.position.y) < 0.01 and bounds.size.y > 0.03 and bounds.size.y < 6.0, holder.name + ": grounded plausible meter scale")
	for index: int in range(5):
		scene.focus_group(index)
		await process_frame
		_expect(scene.camera.global_transform.is_finite() and scene.camera.position.distance_to(scene.target) > 3.0, "Valid inspection camera " + str(index))
		if OS.get_cmdline_user_args().has("--capture"):
			await RenderingServer.frame_post_draw
			DirAccess.make_dir_recursive_absolute("res://.godot/checks/environment")
			var result: Error = root.get_texture().get_image().save_png("res://.godot/checks/environment/group_%d.png" % index)
			_expect(result == OK, "Rendered inspection group " + str(index))
	if OS.get_cmdline_user_args().has("--capture"):
		var viewpoints: Array[Vector3] = [Vector3(12,1.65,-10), Vector3(-3,1.65,-7)]
		var targets: Array[Vector3] = [Vector3(4,1.4,-10), Vector3(-14,1.65,-10)]
		for index: int in range(2):
			scene.camera.position = viewpoints[index]
			scene.camera.look_at(targets[index])
			scene.get_node("HUD/Title").text = "ASSET-PRÜFUNG · Augenhöhe · " + ("Cargo offen" if index == 0 else "Halle außen")
			await process_frame
			await RenderingServer.frame_post_draw
			_expect(root.get_texture().get_image().save_png("res://.godot/checks/environment/eye_%d.png" % index) == OK, "Rendered eye-height building inspection " + str(index))
	scene.queue_free()
	await process_frame
	print("Environment preview checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)
func _expect(value: bool, description: String) -> void:
	checks += 1
	if value:
		print("PASS: ", description)
	else:
		failures += 1
		push_error("FAIL: " + description)

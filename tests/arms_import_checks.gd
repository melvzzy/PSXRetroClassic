extends SceneTree
## Import/clip smoke test. Optional -- --capture requires a real graphics driver.
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var preview: Node3D = load("res://scenes/previews/arms_preview.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var player: AnimationPlayer = preview.animation_player
	var skeleton: Skeleton3D = preview.skeleton
	var mesh: MeshInstance3D = preview.mesh
	_expect(skeleton.get_bone_count() == 52 and mesh.skin != null and mesh.skin.get_bind_count() == 52, "52-bone skeleton and skin bindings imported")
	_expect(mesh.get_node(mesh.skeleton) == skeleton, "Mesh explicitly resolves its imported skeleton")
	_expect(mesh.mesh.get_surface_count() == 1, "Single arms mesh with one material surface")
	var arrays: Array = mesh.mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var weights_valid: bool = weights.size() == vertices.size() * 4
	for vertex: int in range(vertices.size()):
		var sum: float = 0.0
		for influence: int in range(4):
			sum += weights[vertex * 4 + influence]
		weights_valid = weights_valid and absf(sum - 1.0) < 0.001
	_expect(weights_valid, "Every mesh vertex has normalized four-influence skin weights")
	print("Mesh rest AABB: ", mesh.get_aabb(), "; vertices: ", vertices.size())
	var camera_bone: int = skeleton.find_bone("camera")
	var camera_height: float = skeleton.get_bone_global_rest(camera_bone).origin.y
	print("Author camera reference height: ", camera_height, " m")
	_expect(absf(camera_height - 1.743155) < 0.001 and preview.get_node("Orientation/Arms").scale.is_equal_approx(Vector3.ONE), "Original meter scale preserved; preview camera matches author reference")
	_expect((preview.get_node("Orientation").basis * Vector3.BACK).is_equal_approx(Vector3.FORWARD), "Preview wrapper converts source +Z forward to gameplay -Z")
	for variant: int in range(2):
		preview.set_texture(variant)
		var texture: Texture2D = preview.preview_material.albedo_texture
		_expect(texture.get_size() == Vector2(512, 512) and texture.get_image().has_mipmaps(), "Texture variant %d resolves at 512x512 with mipmaps" % variant)
	var clip_count: int = 0
	for clip: StringName in player.get_animation_list():
		if clip == &"RESET":
			continue
		clip_count += 1
		var animation: Animation = player.get_animation(clip)
		var root_node: Node = player.get_node(player.root_node)
		var tracks_valid: bool = animation.length > 0.0 and animation.get_track_count() > 0
		for track: int in range(animation.get_track_count()):
			var path: NodePath = animation.track_get_path(track)
			var target: Node = root_node.get_node_or_null(NodePath(path.get_concatenated_names()))
			tracks_valid = tracks_valid and target != null
			if target is Skeleton3D and path.get_subname_count() > 0:
				tracks_valid = tracks_valid and (target as Skeleton3D).find_bone(path.get_subname(0)) >= 0
		player.play(clip)
		player.seek(0.0, true)
		player.pause()
		var start: Array[Transform3D] = []
		for bone: int in range(skeleton.get_bone_count()):
			start.append(skeleton.get_bone_pose(bone))
		player.seek(animation.length * 0.55, true)
		var moved: bool = false
		var finite: bool = true
		for bone: int in range(skeleton.get_bone_count()):
			var pose: Transform3D = skeleton.get_bone_pose(bone)
			moved = moved or not pose.is_equal_approx(start[bone])
			finite = finite and pose.is_finite()
		_expect(tracks_valid and finite and (moved or clip == &"rest"), "%s: valid targets, finite poses, animated bones (%.3f s)" % [clip, animation.length])
	_expect(clip_count == 18, "All 18 source clips are available, including short rest pose")
	player.play("jab_R")
	player.seek(0.0, true)
	await create_timer(0.1).timeout
	_expect(player.is_playing() and player.current_animation_position > 0.05, "AnimationPlayer advances during actual playback")
	preview.get_node("HUD/Panel/Playback/PlayPause").pressed.emit()
	_expect(not player.is_playing(), "Preview Pause button pauses playback")
	preview.get_node("HUD/Panel/Playback/PlayPause").pressed.emit()
	_expect(player.is_playing(), "Preview Play button resumes playback")
	var rest_index: int = 0
	for index: int in range(preview.clips.item_count):
		if preview.clips.get_item_text(index) == "rest":
			rest_index = index
	preview.get_node("HUD/Panel/Playback/Repeat").button_pressed = false
	preview.play_clip(rest_index)
	await create_timer(0.15).timeout
	_expect(not player.is_playing() and is_equal_approx(preview.scrub.value, 1.0), "Non-looping clip ends with a valid timeline at its final pose")
	preview.get_node("HUD/Panel/Playback/Restart").pressed.emit()
	_expect(player.is_playing() and player.current_animation_position < 0.01, "Restart button restarts the selected clip")
	if OS.get_cmdline_user_args().has("--capture"):
		if DisplayServer.get_name() == "headless":
			_expect(false, "Capture requires a non-headless renderer")
		else:
			DirAccess.make_dir_recursive_absolute("res://.godot/checks/arms_captures")
			for clip: String in ["guard_idle", "jab_R", "finger_gun_fire", "knife_hit_01"]:
				for index: int in range(preview.clips.item_count):
					if preview.clips.get_item_text(index) == clip:
						preview.play_clip(index)
				player.pause()
				preview.scrub.drag_started.emit()
				preview.scrub.value_changed.emit(0.55)
				preview.scrub.drag_ended.emit(true)
				preview.set_view(0)
				preview.set_texture(0)
				await _capture(clip.replace(".", "_") + "_bare", mesh)
			preview.set_view(1)
			preview.set_texture(1)
			await _capture("overview_gloves", mesh)
			preview.set_view(0)
			for index: int in range(preview.clips.item_count):
				if preview.clips.get_item_text(index) == "guard_idle":
					preview.play_clip(index)
			player.pause()
			preview.scrub.drag_started.emit()
			preview.scrub.value_changed.emit(0.55)
			preview.scrub.drag_ended.emit(true)
			await _capture("guard_idle_gloves", mesh)
	preview.queue_free()
	await process_frame
	print("Arms checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures > 0 else 0)

func _capture(name: String, mesh: MeshInstance3D) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var baked: ArrayMesh = mesh.bake_mesh_from_current_skeleton_pose()
	_expect(baked != null and baked.get_aabb().size.length() > 0.1, "GPU skinning produces geometry: " + name)
	print("Skinned AABB ", name, ": ", baked.get_aabb())
	var image: Image = root.get_texture().get_image()
	_expect(image != null and not image.is_empty() and image.save_png("res://.godot/checks/arms_captures/%s.png" % name) == OK, "Rendered capture: " + name)

func _expect(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

extends SceneTree
var checks: int = 0
var failures: int = 0
var gun: TestFirearm
var view: Node3D
var actor: FPSController
var shots: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var game: Node3D = load("res://scenes/startup.tscn").instantiate()
	game.show_arms = true
	root.add_child(game)
	actor = game.get_node("Player")
	gun = actor.get_node("Head/Camera3D/ViewmodelMount/TestFirearm")
	view = gun.get_node("Visuals/ModelMount/MakarovViewmodel")
	gun.fired.connect(func() -> void: shots += 1)
	await _frames(20)
	var skeleton: Skeleton3D = view.skeleton
	var source: Node3D = load("res://assets/source/drillimpact_first_person_arms/arms_rig.glb").instantiate()
	root.add_child(source)
	source.visible = false
	var original: Skeleton3D = source.find_child("Skeleton3D", true, false)
	var animation: AnimationPlayer = source.find_child("AnimationPlayer", true, false)
	animation.play("finger_gun_idle")
	animation.seek(0.3, true)
	animation.pause()
	for side: String in ["R", "L"]:
		for finger: String in ["f_index", "f_middle", "f_ring", "f_pinky", "thumb"]:
			var changed: int = 0
			for joint: int in range(1, 4):
				var bone: int = skeleton.find_bone("%s.%02d.%s" % [finger, joint, side])
				if not skeleton.get_bone_pose_rotation(bone).is_equal_approx(original.get_bone_pose_rotation(bone)):
					changed += 1
			_expect(changed == 3, "%s.%s has three weapon-specific finger joint poses" % [finger, side])
	var hand_r: int = skeleton.find_bone("hand.R")
	var hand_l: int = skeleton.find_bone("hand.L")
	var rest_l: Transform3D = skeleton.get_bone_global_pose(hand_l)
	var grip: Transform3D = (skeleton.global_transform * skeleton.get_bone_global_pose(hand_r)).affine_inverse() * view.pistol.global_transform
	_expect(skeleton.get_bone_global_pose(hand_l).origin.distance_to(skeleton.get_bone_global_pose(hand_r).origin) < 0.1, "Support wrist reaches the pistol hand")
	await _capture("hands_idle")
	await _detail_capture()
	Input.action_press("aim")
	await _frames(30)
	var sight: Node3D = view.pistol.get_node("SightLine")
	_expect(actor.camera.unproject_position(sight.global_position).distance_to(root.get_visible_rect().size * 0.5) < 2.0, "Two-hand ADS remains centered")
	_expect(skeleton.get_bone_global_pose(hand_l).is_equal_approx(rest_l), "ADS retains the support grip without independent hand drift")
	await _capture("hands_ads")
	Input.action_release("aim")
	await _frames(25)
	_button(true)
	await _frames(1)
	_button(false)
	await _frames(1)
	_expect(shots == 1 and gun.magazine == 11, "Real shot event drives the pose without duplicate fire")
	var slide: Node3D = view.pistol.get_part("Slide")
	var travel: float = slide.position.z - view._slide_rest.z
	_expect(travel > 0.0 and is_equal_approx(view._moving_parts[0].position.z - view._part_origins[0].z, travel) and is_equal_approx(view._moving_parts[1].position.z - view._part_origins[1].z, travel), "Slide, sight and extractor travel together")
	await _capture("hands_firing")
	await _frames(30)
	_key(KEY_R)
	await _frames(10)
	_expect(gun.is_reloading and gun.get_reload_progress() > 0.0 and view._reload_reach > 0.0, "Reload presentation follows the authoritative timer")
	await _capture("hands_reload_reach")
	await _frames(25)
	_expect(view._reload_pull > 0.8 and view._magazine.position.y < view._magazine_rest.y, "Support hand withdraws the magazine during the middle phase")
	var hand_magazine: Transform3D = (skeleton.global_transform * skeleton.get_bone_global_pose(hand_l)).affine_inverse() * view._magazine.global_transform
	_expect(hand_magazine.origin.distance_to(view._magazine_grip.origin) < 0.002, "Withdrawn magazine remains attached to the support hand")
	_expect(((skeleton.global_transform * skeleton.get_bone_global_pose(hand_r)).affine_inverse() * view.pistol.global_transform).is_equal_approx(grip), "Reload never detaches the pistol from its firing hand")
	await _capture("hands_reload_withdraw")
	await _frames(32)
	_expect(gun.is_reloading and view._reload_pull < 0.2 and gun.magazine == 11, "Magazine reseats before ammunition transfers")
	await _capture("hands_reload_reseat")
	await _frames(35)
	_expect(not gun.is_reloading and gun.magazine == 12 and gun.reserve == 47, "Reload completes once with original ammo rules")
	_expect(skeleton.get_bone_global_pose(hand_l).origin.distance_to(rest_l.origin) < 0.002, "Support hand smoothly returns to its original grip")
	_key(KEY_X)
	await _frames(20)
	_expect(gun.is_holstered and not view.pistol.visible and view.visible, "Holster keeps relaxed arms visible")
	await _capture("hands_holstered")
	_key(KEY_X)
	await _frames(25)
	_expect(skeleton.get_bone_global_pose(hand_l).is_equal_approx(rest_l), "Drawing restores all authored support joints")
	gun.magazine = 10
	_key(KEY_R)
	await _frames(35)
	actor.set_mouse_capture(false)
	await _frames(20)
	_expect(not gun.is_reloading and gun.magazine == 10 and gun.reserve == 47 and view._magazine.position.is_equal_approx(view._magazine_rest), "Focus cancellation restores magazine without granting ammo")
	_expect(skeleton.get_bone_global_pose(hand_l).origin.distance_to(rest_l.origin) < 0.002, "Interrupted reload returns the hand to the grip")
	var valid: bool = true
	for bone: int in range(skeleton.get_bone_count()):
		var pose: Transform3D = skeleton.get_bone_global_pose(bone)
		valid = valid and pose.is_finite() and absf(pose.basis.determinant() - 1.0) < 0.001
	_expect(valid, "All final skeleton transforms are finite with unit scale")
	# Evaluate the actual hierarchical pose path in fixed blend steps, independent
	# of GPU stalls and the number of render frames per physics tick.
	var max_step: float = 0.0
	for target: Array[Transform3D] in [view._relaxed_poses, view._pickup_poses, view._pulled_poses]:
		var last: Vector3
		for step: int in range(51):
			for bone: int in range(skeleton.get_bone_count()):
				skeleton.set_bone_pose(bone, view._ready_poses[bone].interpolate_with(target[bone], step / 50.0))
			var point: Vector3 = skeleton.get_bone_global_pose(hand_l).origin
			if step > 0:
				max_step = maxf(max_step, point.distance_to(last))
			last = point
	for bone: int in range(skeleton.get_bone_count()):
		skeleton.set_bone_pose(bone, view._ready_poses[bone])
	_expect(max_step < 0.08, "Holster/reload skeletal pose paths remain continuous in fixed blend steps")
	source.queue_free()
	game.queue_free()
	await process_frame
	print("Arms weapon polish checks: %d passed, %d failed" % [checks - failures, failures])
	quit(1 if failures else 0)

func _detail_capture() -> void:
	if not OS.get_cmdline_user_args().has("--capture"):
		return
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.near = 0.01
	camera.fov = 55.0
	camera.global_position = view.pistol.global_transform * Vector3(0.23, -0.02, -0.2)
	camera.look_at(view.pistol.global_transform * Vector3(0.0, -0.02, 0.04))
	camera.current = true
	await _capture("hands_grip_detail")
	actor.camera.current = true
	camera.queue_free()

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _button(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	Input.parse_input_event(event)

func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
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

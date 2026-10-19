extends Node3D
## Presentation adapter only. The existing firearm remains the sole state owner.
@export var firearm: TestFirearm
@export var use_imported_visuals: bool = true
@onready var pistol: WeaponAsset = $Pistol
@onready var skeleton: Skeleton3D = $ArmsOrientation/Arms.find_child("Skeleton3D", true, false)
var _slide: Node3D
var _magazine: Node3D
var _empty_magazine: Node3D
var _slide_rest: Vector3
var _magazine_rest_transform: Transform3D
var _magazine_grip: Transform3D
var _magazine_rest: Vector3
var _slide_kick: float = 0.0
var _muzzle_rest: Transform3D
var _placeholder: Node3D
var _hand: int
var _grip_offset: Transform3D
var _hip_transform: Transform3D
var _ads_blend: float = 0.0
var _ready_poses: Array[Transform3D] = []
var _relaxed_poses: Array[Transform3D] = []
var _pickup_poses: Array[Transform3D] = []
var _pulled_poses: Array[Transform3D] = []
var _reload_reach: float = 0.0
var _reload_pull: float = 0.0
var _previous_reach: float = 0.0
var _previous_pull: float = 0.0
var _moving_parts: Array[Node3D] = []
var _part_origins: Array[Vector3] = []
var _pose_target_offset: Vector3 = Vector3.ZERO
var _trigger_bone: int
var _trigger_active: bool = false
var _motion_phase: float = 0.0
var _motion: Vector3 = Vector3.ZERO
var _pose_blend: float = 0.0
var _meters_per_unit: float

func _ready() -> void:
	if not firearm.show_arms:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
		var inactive_player: AnimationPlayer = $ArmsOrientation/Arms.find_child("AnimationPlayer", true, false)
		inactive_player.active = false
		return
	use_imported_visuals = firearm.use_imported_visuals
	var player: AnimationPlayer = $ArmsOrientation/Arms.find_child("AnimationPlayer", true, false)
	# Source arm reference; weapon-specific finger/support poses are authored below.
	player.play("finger_gun_idle")
	player.seek(0.3, true)
	player.pause()
	var arms_mesh: MeshInstance3D = $ArmsOrientation/Arms.find_child("ArmsMesh", true, false)
	var arms_material: StandardMaterial3D = arms_mesh.get_active_material(0).duplicate()
	arms_material.albedo_texture = preload("res://assets/source/drillimpact_first_person_arms/arms_01.png")
	arms_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	arms_mesh.material_override = arms_material
	_trigger_bone = skeleton.find_bone("f_index.02.R")
	_hand = skeleton.find_bone("hand.R")
	var hand: Transform3D = global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(_hand)
	# Preserve the established grip and orientation as a hand-local bind transform.
	pistol.position = hand.origin + Vector3(-0.008, 0.04, -0.135)
	_author_grip()
	hand = global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(_hand)
	_grip_offset = hand.affine_inverse() * pistol.transform
	var sight: Node3D = pistol.get_node("SightLine")
	var sight_local: Vector3 = to_local(sight.global_position)
	position = Vector3(-firearm.ads_position.x - sight_local.x,
		-firearm.ads_position.y - sight_local.y, -pistol.position.z)
	_hip_transform = transform
	# Read the final animated pose, including future SkeletonModifier3D results.
	skeleton.skeleton_updated.connect(_sync_hand)
	_slide = pistol.get_part("Slide")
	_magazine = pistol.get_part("Magazine-Full")
	_empty_magazine = pistol.get_part("Magazine-Empty")
	for part_name: String in ["Sight", "Extractor"]:
		var part: Node3D = pistol.get_part(part_name)
		_moving_parts.append(part)
		_part_origins.append(part.position)
	_slide_rest = _slide.position
	_magazine_rest = _magazine.position
	_magazine_rest_transform = _magazine.transform
	_meters_per_unit = pistol.get_node("Source").scale.x
	_placeholder = get_parent().get_node("Placeholder")
	_muzzle_rest = firearm.get_node("Visuals/Muzzle").transform
	for node: Node in find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	firearm.fired.connect(_on_fired)
	firearm.ammunition_changed.connect(_on_ammunition_changed)
	firearm.actor.mouse_capture_changed.connect(_on_capture_changed)
	for bone: int in range(skeleton.get_bone_count()):
		_ready_poses.append(skeleton.get_bone_pose(bone))
	_author_support(Vector3(-0.06, -0.055, 0.14))
	_magazine_grip = (skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("hand.L"))).affine_inverse() * _magazine.global_transform
	for bone: int in range(skeleton.get_bone_count()):
		_pickup_poses.append(skeleton.get_bone_pose(bone))
	_author_support(Vector3(-0.06, -0.13, 0.165))
	for bone: int in range(skeleton.get_bone_count()):
		_pulled_poses.append(skeleton.get_bone_pose(bone))
	player.play("relax")
	player.seek(0.3, true)
	player.pause()
	for bone: int in range(skeleton.get_bone_count()):
		_relaxed_poses.append(skeleton.get_bone_pose(bone))
		skeleton.set_bone_pose(bone, _ready_poses[bone])
	set_imported_visible(use_imported_visuals)

func _bone_in_pistol(bone: int) -> Transform3D:
	return pistol.global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(bone)

func _point_joint(bone_name: String, child_name: String, target: Vector3) -> void:
	# Pose authoring at startup only: rotate a joint toward a calibrated point.
	# There is no runtime IK solver or retargeting layer.
	if bone_name.ends_with(".L") and (bone_name.begins_with("f_") or bone_name.begins_with("thumb")):
		target += _pose_target_offset
	var bone: int = skeleton.find_bone(bone_name)
	var child: int = skeleton.find_bone(child_name)
	var current: Transform3D = _bone_in_pistol(bone)
	var direction: Vector3 = _bone_in_pistol(child).origin - current.origin
	var turn := Quaternion(direction.normalized(), (target - current.origin).normalized())
	_set_joint_basis(bone, Basis(turn) * current.basis)

func _point_tip(bone_name: String, target: Vector3) -> void:
	if bone_name.ends_with(".L"):
		target += _pose_target_offset
	var bone: int = skeleton.find_bone(bone_name)
	var current: Transform3D = _bone_in_pistol(bone)
	var turn := Quaternion(current.basis.y.normalized(), (target - current.origin).normalized())
	_set_joint_basis(bone, Basis(turn) * current.basis)

func _set_joint_basis(bone: int, pistol_basis: Basis) -> void:
	var parent: int = skeleton.get_bone_parent(bone)
	var parent_basis: Basis = _bone_in_pistol(parent).basis
	skeleton.set_bone_pose_rotation(bone, (parent_basis.inverse() * pistol_basis).orthonormalized().get_rotation_quaternion())

func _author_grip() -> void:
	# Coordinates are meters in the normalized Makarov frame, not source FBX units.
	_point_joint("f_middle.01.R", "f_middle.02.R", Vector3(-0.025, -0.012, 0.017))
	_point_joint("f_middle.02.R", "f_middle.03.R", Vector3(-0.021, -0.016, 0.048))
	_point_joint("f_ring.01.R", "f_ring.02.R", Vector3(-0.028, -0.034, 0.018))
	_point_joint("f_ring.02.R", "f_ring.03.R", Vector3(-0.018, -0.037, 0.05))
	_point_joint("f_pinky.01.R", "f_pinky.02.R", Vector3(-0.026, -0.055, 0.021))
	_point_joint("f_pinky.02.R", "f_pinky.03.R", Vector3(-0.014, -0.056, 0.05))
	_point_joint("f_index.01.R", "f_index.02.R", Vector3(-0.008, 0.012, -0.004))
	_point_joint("f_index.02.R", "f_index.03.R", Vector3(-0.007, 0.014, -0.02))
	_point_joint("thumb.01.R", "thumb.02.R", Vector3(-0.022, 0.019, 0.064))
	_point_joint("thumb.02.R", "thumb.03.R", Vector3(-0.022, 0.02, 0.029))
	_point_tip("f_middle.03.R", Vector3(-0.021, -0.017, 0.07))
	_point_tip("f_ring.03.R", Vector3(-0.021, -0.039, 0.072))
	_point_tip("f_pinky.03.R", Vector3(-0.02, -0.058, 0.071))
	_point_tip("f_index.03.R", Vector3(0.003, 0.015, -0.009))
	_point_tip("thumb.03.R", Vector3(-0.019, 0.018, 0.01))
	_author_support(Vector3(-0.07, -0.045, 0.085))

func _author_support(target: Vector3) -> void:
	_pose_target_offset = target - Vector3(-0.07, -0.045, 0.085)
	# Fixed pose authoring from the source bone lengths, only at initialization.
	var shoulder: Vector3 = _bone_in_pistol(skeleton.find_bone("upper_arm.L")).origin
	var elbow: Vector3 = _bone_in_pistol(skeleton.find_bone("forearm.L")).origin
	var wrist: Vector3 = _bone_in_pistol(skeleton.find_bone("hand.L")).origin
	var upper_length: float = shoulder.distance_to(elbow)
	var lower_length: float = elbow.distance_to(wrist)
	var direction: Vector3 = (target - shoulder).normalized()
	var distance: float = shoulder.distance_to(target)
	var along: float = (upper_length * upper_length - lower_length * lower_length + distance * distance) / (2.0 * distance)
	var down: Vector3 = (Vector3.DOWN - direction * Vector3.DOWN.dot(direction)).normalized()
	var elbow_target: Vector3 = shoulder + direction * along + down * sqrt(maxf(0.0, upper_length * upper_length - along * along))
	_point_joint("upper_arm.L", "forearm.L", elbow_target)
	_point_joint("forearm.L", "hand.L", target)
	var mirror := Basis(Vector3(-1, 0, 0), Vector3.UP, Vector3.BACK)
	var right_basis: Basis = _bone_in_pistol(skeleton.find_bone("hand.R")).basis
	_set_joint_basis(skeleton.find_bone("hand.L"), Basis(Vector3.UP, deg_to_rad(-40.0)) * mirror * right_basis * mirror)
	_point_joint("f_index.01.L", "f_index.02.L", Vector3(0.008, -0.012, 0.0))
	_point_joint("f_index.02.L", "f_index.03.L", Vector3(0.019, -0.015, 0.028))
	_point_joint("f_middle.01.L", "f_middle.02.L", Vector3(0.014, -0.036, 0.002))
	_point_joint("f_middle.02.L", "f_middle.03.L", Vector3(0.02, -0.038, 0.032))
	_point_joint("f_ring.01.L", "f_ring.02.L", Vector3(0.013, -0.055, 0.01))
	_point_joint("f_ring.02.L", "f_ring.03.L", Vector3(0.016, -0.06, 0.036))
	_point_joint("f_pinky.01.L", "f_pinky.02.L", Vector3(0.003, -0.071, 0.021))
	_point_joint("f_pinky.02.L", "f_pinky.03.L", Vector3(0.012, -0.071, 0.04))
	_point_joint("thumb.01.L", "thumb.02.L", Vector3(-0.032, 0.005, 0.05))
	_point_joint("thumb.02.L", "thumb.03.L", Vector3(-0.028, 0.015, 0.014))

	_point_tip("f_index.03.L", Vector3(0.016, -0.016, 0.05))
	_point_tip("f_middle.03.L", Vector3(0.01, -0.038, 0.052))
	_point_tip("f_ring.03.L", Vector3(0.008, -0.059, 0.055))
	_point_tip("f_pinky.03.L", Vector3(0.005, -0.072, 0.055))
	_point_tip("thumb.03.L", Vector3(-0.024, 0.017, -0.003))

func set_imported_visible(value: bool) -> void:
	use_imported_visuals = value
	visible = value
	_placeholder.visible = not value
	var muzzle: Node3D = firearm.get_node("Visuals/Muzzle")
	if value:
		_sync_hand()
	else:
		muzzle.transform = _muzzle_rest

func _sync_hand() -> void:
	# Always rebuild from the current bone pose; never accumulate previous offsets.
	pistol.transform = global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(_hand) * _grip_offset
	transform = _hip_transform
	var sight: Node3D = pistol.get_node("SightLine")
	var local_sight: Transform3D = global_transform.affine_inverse() * sight.global_transform
	var aligned_basis: Basis = local_sight.basis.orthonormalized().inverse()
	var aligned_origin: Vector3 = aligned_basis * local_sight.origin
	var ads_transform := Transform3D(aligned_basis, Vector3(
		-firearm.ads_position.x - aligned_origin.x,
		-firearm.ads_position.y - aligned_origin.y, _hip_transform.origin.z))
	transform = _hip_transform.interpolate_with(ads_transform, _ads_blend)
	# Lower the assembly through the transition; relaxed arms return without the pistol.
	position.y -= 0.28 * sin(PI * firearm.holster_amount)
	position += _motion * (1.0 - _ads_blend) * (1.0 - firearm.holster_amount)
	if use_imported_visuals and is_instance_valid(_placeholder):
		var muzzle: Node3D = firearm.get_node("Visuals/Muzzle")
		muzzle.transform = muzzle.get_parent().global_transform.affine_inverse() * pistol.get_node("Muzzle").global_transform
	if is_instance_valid(_magazine):
		_sync_magazine()

func _on_fired() -> void:
	_slide_kick = 0.025

func _on_ammunition_changed(magazine: int, _reserve: int) -> void:
	_magazine.visible = magazine > 0
	_empty_magazine.visible = magazine == 0

func _on_capture_changed(captured: bool) -> void:
	if not captured:
		_slide_kick = 0.0
		_slide.position = _slide_rest
		# The authoritative reload is already canceled; ease the hand/prop home.
		for i: int in range(_moving_parts.size()):
			_moving_parts[i].position = _part_origins[i]

func _process(delta: float) -> void:
	_ads_blend = lerpf(_ads_blend, 1.0 if firearm.is_aiming else 0.0, 1.0 - exp(-firearm.ads_response * delta))
	var amount: float = firearm.holster_amount
	var progress: float = firearm.get_reload_progress()
	var reach: float = 0.0
	var pull: float = 0.0
	if firearm.is_reloading:
		reach = smoothstep(0.0, 0.16, progress) * (1.0 - smoothstep(0.82, 1.0, progress))
		pull = smoothstep(0.18, 0.38, progress) * (1.0 - smoothstep(0.6, 0.8, progress))
	var response: float = 1.0 - exp(-35.0 * delta)
	_reload_reach = lerpf(_reload_reach, reach, response)
	_reload_pull = lerpf(_reload_pull, pull, response)
	if _reload_reach < 0.0001:
		_reload_reach = 0.0
	if _reload_pull < 0.0001:
		_reload_pull = 0.0
	if not is_equal_approx(amount, _pose_blend) or not is_equal_approx(_reload_reach, _previous_reach) or not is_equal_approx(_reload_pull, _previous_pull):
		for bone: int in range(skeleton.get_bone_count()):
			var reload_pose: Transform3D = _pickup_poses[bone].interpolate_with(_pulled_poses[bone], _reload_pull)
			var pose: Transform3D = _ready_poses[bone].interpolate_with(reload_pose, _reload_reach)
			skeleton.set_bone_pose(bone, pose.interpolate_with(_relaxed_poses[bone], amount))
		_pose_blend = amount
		_previous_reach = _reload_reach
		_previous_pull = _reload_pull
	_motion_phase += delta * (9.0 if firearm.actor.velocity.length() > 5.5 else 7.0)
	var moving: float = clampf(Vector2(firearm.actor.velocity.x, firearm.actor.velocity.z).length() / 8.0, 0.0, 1.0)
	var target_motion := Vector3(sin(_motion_phase) * 0.002, sin(_motion_phase * 2.0) * 0.001, 0.0) * moving
	_motion = _motion.lerp(target_motion, 1.0 - exp(-16.0 * delta))
	pistol.visible = amount < 0.6
	_placeholder.visible = not use_imported_visuals and amount < 0.6
	_placeholder.position.y = -0.28 * sin(PI * amount)
	_sync_hand()
	_slide_kick *= exp(-30.0 * delta)
	if _slide_kick > 0.00001 or _trigger_active:
		var rotation: Quaternion = _ready_poses[_trigger_bone].interpolate_with(_relaxed_poses[_trigger_bone], amount).basis.get_rotation_quaternion()
		skeleton.set_bone_pose_rotation(_trigger_bone, rotation * Quaternion(Vector3.RIGHT, -0.1 * _slide_kick / 0.025 * (1.0 - amount)))
		_trigger_active = _slide_kick > 0.00001
	# Parts are in the FBX's pre-normalization coordinates: convert meters back.
	_slide.position = _slide_rest + Vector3(0, 0, _slide_kick / _meters_per_unit)
	for i: int in range(_moving_parts.size()):
		_moving_parts[i].position = _part_origins[i] + Vector3(0, 0, _slide_kick / _meters_per_unit)
	_sync_magazine()

func _sync_magazine() -> void:
	# During withdrawal the magazine is hand-bound, not animated independently.
	# Blend the binding only around pickup/reseat so the seated magazine stays fixed.
	var left_hand: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(skeleton.find_bone("hand.L"))
	var attached: Transform3D = _magazine.get_parent().global_transform.affine_inverse() * left_hand * _magazine_grip
	var weight: float = smoothstep(0.0, 0.1, _reload_pull)
	_magazine.transform = _magazine_rest_transform.interpolate_with(attached, weight)
	_empty_magazine.transform = _magazine.transform

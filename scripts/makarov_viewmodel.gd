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
var _pose_blend: float = 0.0
var _meters_per_unit: float

func _ready() -> void:
	var player: AnimationPlayer = $ArmsOrientation/Arms.find_child("AnimationPlayer", true, false)
	# A frozen, explicitly provisional hold pose, not a retargeted fire/reload clip.
	player.play("finger_gun_idle")
	player.seek(0.3, true)
	player.pause()
	var arms_mesh: MeshInstance3D = $ArmsOrientation/Arms.find_child("ArmsMesh", true, false)
	var arms_material: StandardMaterial3D = arms_mesh.get_active_material(0).duplicate()
	arms_material.albedo_texture = preload("res://assets/source/drillimpact_first_person_arms/arms_01.png")
	arms_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	arms_mesh.material_override = arms_material
	# Lower the finger-pistol thumb into a provisional pistol hold. This is a
	# local static pose correction, not a claim of a supplied weapon animation.
	var thumb: int = skeleton.find_bone("thumb.01.R")
	var parent_basis: Basis = skeleton.get_bone_global_pose(skeleton.get_bone_parent(thumb)).basis
	var axis: Vector3 = parent_basis.inverse() * ($ArmsOrientation.basis.inverse() * Vector3.RIGHT)
	skeleton.set_bone_pose_rotation(thumb, Quaternion(axis.normalized(), deg_to_rad(-80.0)) * skeleton.get_bone_pose_rotation(thumb))
	_hand = skeleton.find_bone("hand.R")
	var hand: Transform3D = global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(_hand)
	# Preserve the established grip and orientation as a hand-local bind transform.
	pistol.position = hand.origin + Vector3(0.0, 0.025, -0.11)
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
	_slide_rest = _slide.position
	_magazine_rest = _magazine.position
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
	player.play("relax")
	player.seek(0.3, true)
	player.pause()
	for bone: int in range(skeleton.get_bone_count()):
		_relaxed_poses.append(skeleton.get_bone_pose(bone))
		skeleton.set_bone_pose(bone, _ready_poses[bone])
	set_imported_visible(use_imported_visuals)

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
	if use_imported_visuals and is_instance_valid(_placeholder):
		var muzzle: Node3D = firearm.get_node("Visuals/Muzzle")
		muzzle.transform = muzzle.get_parent().global_transform.affine_inverse() * pistol.get_node("Muzzle").global_transform

func _on_fired() -> void:
	_slide_kick = 0.025

func _on_ammunition_changed(magazine: int, _reserve: int) -> void:
	_magazine.visible = magazine > 0
	_empty_magazine.visible = magazine == 0

func _on_capture_changed(captured: bool) -> void:
	if not captured:
		_slide_kick = 0.0
		_slide.position = _slide_rest
		_magazine.position = _magazine_rest
		_empty_magazine.position = _magazine_rest

func _process(delta: float) -> void:
	_ads_blend = lerpf(_ads_blend, 1.0 if firearm.is_aiming else 0.0, 1.0 - exp(-firearm.ads_response * delta))
	var amount: float = firearm.holster_amount
	if not is_equal_approx(amount, _pose_blend):
		for bone: int in range(skeleton.get_bone_count()):
			skeleton.set_bone_pose(bone, _ready_poses[bone].interpolate_with(_relaxed_poses[bone], amount))
		_pose_blend = amount
	pistol.visible = amount < 0.6
	_placeholder.visible = not use_imported_visuals and amount < 0.6
	_placeholder.position.y = -0.28 * sin(PI * amount)
	_sync_hand()
	_slide_kick *= exp(-30.0 * delta)
	# Parts are in the FBX's pre-normalization coordinates: convert meters back.
	_slide.position = _slide_rest + Vector3(0, 0, _slide_kick / _meters_per_unit)
	var reload_offset: float = 0.065 if firearm.is_reloading else 0.0
	_magazine.position = _magazine.position.move_toward(_magazine_rest - Vector3(0, reload_offset / _meters_per_unit, 0), delta * 12.0)
	_empty_magazine.position = _magazine.position

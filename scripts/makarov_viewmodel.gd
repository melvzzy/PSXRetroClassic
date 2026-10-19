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
var _muzzle_rest: Vector3
var _placeholder: Node3D
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
	var hand: Transform3D = $ArmsOrientation.transform * skeleton.get_bone_global_pose(skeleton.find_bone("hand.R"))
	var pistol_origin: Vector3 = hand.origin + Vector3(0.0, 0.025, -0.11)
	pistol.position = pistol_origin
	# Keep the old weapon's sight height and ADS offsets. Only visual geometry moves.
	position = -pistol_origin + Vector3(0.0, 0.05515, 0.0)
	_slide = pistol.get_part("Slide")
	_magazine = pistol.get_part("Magazine-Full")
	_empty_magazine = pistol.get_part("Magazine-Empty")
	_slide_rest = _slide.position
	_magazine_rest = _magazine.position
	_meters_per_unit = pistol.get_node("Source").scale.x
	_placeholder = get_parent().get_node("Placeholder")
	_muzzle_rest = firearm.get_node("Visuals/Muzzle").position
	for node: Node in find_children("*", "MeshInstance3D", true, false):
		(node as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	firearm.fired.connect(_on_fired)
	firearm.ammunition_changed.connect(_on_ammunition_changed)
	firearm.actor.mouse_capture_changed.connect(_on_capture_changed)
	set_imported_visible(use_imported_visuals)

func set_imported_visible(value: bool) -> void:
	use_imported_visuals = value
	visible = value
	_placeholder.visible = not value
	var muzzle: Node3D = firearm.get_node("Visuals/Muzzle")
	muzzle.position = position + pistol.position + pistol.get_node("Muzzle").position if value else _muzzle_rest

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
	_slide_kick *= exp(-30.0 * delta)
	# Parts are in the FBX's pre-normalization coordinates: convert meters back.
	_slide.position = _slide_rest + Vector3(0, 0, _slide_kick / _meters_per_unit)
	var reload_offset: float = 0.065 if firearm.is_reloading else 0.0
	_magazine.position = _magazine.position.move_toward(_magazine_rest - Vector3(0, reload_offset / _meters_per_unit, 0), delta * 12.0)
	_empty_magazine.position = _magazine.position

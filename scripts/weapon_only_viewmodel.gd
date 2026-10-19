extends Node3D
## Shared model presentation. TestFirearm owns all gameplay and input states.
@export var firearm: TestFirearm
var model: WeaponAsset
var _profile: TestWeaponProfile
var _parts: Array[Node3D] = []
var _origins: Array[Vector3] = []
var _kick: float = 0.0
var _aim_blend: float = 0.0
var _muzzle_rest: Transform3D
var _placeholder: Node3D
var _sight: Node3D
var _model_muzzle: Node3D
var _muzzle: Node3D
var _imported: bool = true

func _ready() -> void:
	_muzzle = firearm.get_node("Visuals/Muzzle")
	_muzzle_rest = firearm.placeholder_muzzle
	_placeholder = firearm.get_node("Visuals/ModelMount/Placeholder")
	_imported = firearm.use_imported_visuals
	firearm.fired.connect(_on_fired)
	firearm.ammunition_changed.connect(_ammunition_changed)
	firearm.actor.mouse_capture_changed.connect(_capture_changed)
	firearm.weapon_changed.connect(_load_profile)
	_load_profile(firearm.test_profile)

func _on_fired() -> void:
	if not firearm.show_arms:
		_kick = _profile.part_travel

func _load_profile(profile: TestWeaponProfile) -> void:
	if is_instance_valid(model):
		remove_child(model)
		model.queue_free()
	model = null
	_parts.clear()
	_origins.clear()
	_kick = 0.0
	_aim_blend = 0.0
	visible = not firearm.show_arms
	set_process(visible)
	if not visible:
		return
	_profile = profile
	model = _profile.model.instantiate()
	add_child(model)
	for part_name: String in _profile.hidden_parts:
		model.get_part(part_name).visible = false
	for part_name: String in _profile.moving_parts:
		var part: Node3D = model.get_part(part_name)
		_parts.append(part)
		_origins.append(part.position)
	for mesh: MeshInstance3D in model.parts.values():
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_sight = model.get_node("SightLine")
	_model_muzzle = model.get_node("Muzzle")
	for player: AnimationPlayer in model.find_children("*", "AnimationPlayer", true, false):
		player.stop()
		player.active = false
	_ammunition_changed(firearm.magazine if firearm.is_node_ready() else _profile.magazine_capacity, 0)
	set_imported_visible(_imported)

func set_imported_visible(value: bool) -> void:
	_imported = value
	if not value:
		_muzzle.transform = _muzzle_rest
	_update_transform()

func _ammunition_changed(magazine: int, _reserve: int) -> void:
	if not is_instance_valid(model):
		return
	var empty: Node3D = model.get_part("Magazine-Empty")
	if empty != null:
		empty.visible = magazine == 0
		model.get_part("Magazine-Full").visible = magazine > 0

func _capture_changed(captured: bool) -> void:
	if not captured:
		_kick = 0.0
		for i: int in range(_parts.size()):
			_parts[i].position = _origins[i]

func _process(delta: float) -> void:
	_aim_blend = lerpf(_aim_blend, 1.0 if firearm.is_aiming else 0.0, 1.0 - exp(-firearm.ads_response * delta))
	_kick *= exp(-30.0 * delta)
	for i: int in range(_parts.size()):
		_parts[i].position = _origins[i] + _parts[i].get_parent().global_basis.inverse() * model.global_basis.z * _kick
	_update_transform()

func _update_transform() -> void:
	# Align the actual sight frame, never the camera or hitscan ray.
	var sight_local: Transform3D = model.transform * _sight.transform
	var ads_basis: Basis = sight_local.basis.orthonormalized().inverse()
	var sight_origin: Vector3 = ads_basis * sight_local.origin
	var ads := Transform3D(ads_basis, Vector3(-firearm.ads_position.x - sight_origin.x, -firearm.ads_position.y - sight_origin.y, 0.0))
	var rotation := Vector3(deg_to_rad(_profile.hip_rotation_degrees.x), deg_to_rad(_profile.hip_rotation_degrees.y), deg_to_rad(_profile.hip_rotation_degrees.z))
	var hip := Transform3D(Basis.from_euler(rotation), Vector3.ZERO)
	transform = hip.interpolate_with(ads, _aim_blend) if _imported else Transform3D.IDENTITY
	var lowered: float = smoothstep(0.0, 1.0, firearm.holster_amount)
	position.y -= 0.45 * lowered
	rotate_x(-0.2 * lowered)
	# Without a hand, magazines stay seated. The existing recoil and smoothed
	# reload tilt move the whole model rather than floating a detached magazine.
	model.visible = _imported and firearm.holster_amount < 0.98
	_placeholder.visible = not _imported and firearm.holster_amount < 0.98
	_placeholder.position.y = -0.45 * lowered
	_placeholder.rotation.x = -0.2 * lowered
	if _imported:
		_muzzle.transform = _muzzle.get_parent().global_transform.affine_inverse() * _model_muzzle.global_transform

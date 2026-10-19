extends Node3D
## Shared model presentation. TestFirearm owns all gameplay and input states.
@export var firearm: TestFirearm
@export_range(0.0, 0.015) var walk_motion: float = 0.004
@export_range(5.0, 35.0) var motion_response: float = 16.0
var model: WeaponAsset
var _profile: TestWeaponProfile
var _parts: Array[Node3D] = []
var _origins: Array[Vector3] = []
var _kick: float = 0.0
var _motion_phase: float = 0.0
var _sprint_blend: float = 0.0
var _ready_hold: float = 0.0
var _movement_pose := Vector3.ZERO
var _movement_rotation := Vector3.ZERO
var _aim_blend: float = 0.0
var _muzzle_rest: Transform3D
var _placeholder_muzzle_local: Transform3D
var _placeholder: Node3D
var _sight: Node3D
var _model_muzzle: Node3D
var _muzzle: Node3D
var _imported: bool = true

func _ready() -> void:
	_muzzle = firearm.get_node("Visuals/Muzzle")
	_muzzle_rest = firearm.placeholder_muzzle
	_placeholder = firearm.get_node("Visuals/ModelMount/Placeholder")
	_placeholder_muzzle_local = _placeholder.global_transform.affine_inverse() * _muzzle.get_parent().global_transform * _muzzle_rest
	_imported = firearm.use_imported_visuals
	firearm.fired.connect(_on_fired)
	firearm.ammunition_changed.connect(_ammunition_changed)
	firearm.actor.mouse_capture_changed.connect(_capture_changed)
	firearm.weapon_changed.connect(_load_profile)
	_load_profile(firearm.test_profile)

func _on_fired() -> void:
	if not firearm.show_arms:
		_kick = _profile.part_travel
		_ready_hold = 0.18

func _load_profile(profile: TestWeaponProfile) -> void:
	if is_instance_valid(model):
		remove_child(model)
		model.queue_free()
	model = null
	_parts.clear()
	_origins.clear()
	_kick = 0.0
	_sprint_blend = 0.0
	_ready_hold = 0.0
	_movement_pose = Vector3.ZERO
	_movement_rotation = Vector3.ZERO
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
	var actor: FPSController = firearm.actor
	var speed: float = Vector2(actor.velocity.x, actor.velocity.z).length()
	var weight: float = clampf(speed / maxf(actor.walk_speed, 0.01), 0.0, 1.0) if actor.is_on_floor() and actor.has_mouse_capture else 0.0
	weight *= pow(1.0 - _aim_blend, 2.0) * (1.0 - firearm.holster_amount)
	if firearm.is_reloading:
		weight = 0.0
	_motion_phase = fmod(_motion_phase + speed * delta * 1.8, TAU)
	_ready_hold = maxf(0.0, _ready_hold - delta)
	var carrying: bool = actor.is_sprinting and actor.is_on_floor() and actor.has_mouse_capture and speed > actor.walk_speed * 1.05
	carrying = carrying and not firearm.is_reloading and not firearm.is_aiming and not firearm.is_holstered and _ready_hold <= 0.0
	# A short shot-owned hold prevents the carry pose pumping between automatic shots.
	var carry_response: float = 12.0 if carrying else 28.0
	_sprint_blend = lerpf(_sprint_blend, 1.0 if carrying else 0.0, 1.0 - exp(-carry_response * delta))
	var response: float = 1.0 - exp(-motion_response * delta)
	var local_velocity: Vector3 = actor.global_basis.inverse() * actor.velocity
	var airborne: float = clampf(-actor.velocity.y * 0.0015, -0.009, 0.014) if not actor.is_on_floor() else 0.0
	var ready_weight: float = pow(1.0 - _aim_blend, 2.0) if actor.has_mouse_capture and not firearm.is_reloading else 0.0
	var motion_target := Vector3(sin(_motion_phase) * walk_motion * weight - local_velocity.x * 0.0005 * ready_weight,
		cos(_motion_phase * 2.0) * walk_motion * 0.5 * weight + airborne * ready_weight, 0.0)
	_movement_pose = _movement_pose.lerp(motion_target, response)
	var roll: float = sin(_motion_phase) * 0.004 * weight - local_velocity.x * 0.0008 * ready_weight
	_movement_rotation = _movement_rotation.lerp(Vector3(0.0, 0.0, roll), response)
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
	var carry: float = smoothstep(0.0, 1.0, _sprint_blend) * pow(1.0 - _aim_blend, 2.0) * (1.0 - firearm.holster_amount)
	var carry_basis: Basis = Basis.IDENTITY.slerp(Basis.from_euler(_profile.sprint_rotation_degrees * (PI / 180.0)), carry)
	var motion_basis: Basis = Basis.from_euler(_movement_rotation) * carry_basis
	var motion_position: Vector3 = _movement_pose + _profile.sprint_offset * carry
	basis = motion_basis * basis
	position += motion_position
	# Guide even long barrels below the screen before hiding them.
	position.y -= 0.65 * lowered
	rotate_x(-0.5 * lowered)
	# Without a hand, magazines stay seated. The existing recoil and smoothed
	# reload tilt move the whole model rather than floating a detached magazine.
	model.visible = _imported and firearm.holster_amount < 0.98
	_placeholder.visible = not _imported and firearm.holster_amount < 0.98
	_placeholder.transform = Transform3D(
		motion_basis * Basis.from_euler(Vector3(-0.5 * lowered, 0, 0)),
		motion_position + Vector3(0, -0.65 * lowered, 0))
	if _imported:
		_muzzle.transform = _muzzle.get_parent().global_transform.affine_inverse() * _model_muzzle.global_transform
	else:
		_muzzle.transform = _muzzle.get_parent().global_transform.affine_inverse() * _placeholder.global_transform * _placeholder_muzzle_local

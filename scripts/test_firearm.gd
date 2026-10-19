class_name TestFirearm
extends Node3D
## One semi-automatic firearm. Queries, impulses and ammo transitions run in physics.
signal ammunition_changed(magazine: int, reserve: int)
signal status_changed(text: String)
signal aim_changed(aiming: bool)
signal fired()
signal hit_confirmed()
signal weapon_changed(profile: TestWeaponProfile)

@export var actor: FPSController
@export var camera: Camera3D
var test_profile: TestWeaponProfile
var show_arms: bool = false
var arms_requested: bool = false
var active_weapon: int = 0
var weapon_profiles: Array[TestWeaponProfile] = []
var _ammunition: Array[Vector2i] = []
var _inactive_cooldowns: Array[float] = []
var _pending_weapon: int = -1
var placeholder_muzzle: Transform3D
var use_imported_visuals: bool = true
@export_group("Firearm")
@export_range(1, 100) var magazine_capacity: int = 12
@export_range(0, 500) var starting_reserve: int = 48
@export_range(0.05, 2.0) var shot_interval: float = 0.18
@export_range(0.1, 5.0) var reload_duration: float = 1.35
@export_range(1.0, 300.0) var shot_range: float = 100.0
@export var damage: float = 25.0
@export var impulse_strength: float = 3.5
@export_range(0.1, 0.5) var holster_duration: float = 0.22
@export_range(0.0, 0.08) var fire_buffer_window: float = 0.06
@export_group("Aim and feel")
@export_range(30.0, 90.0) var ads_fov: float = 60.0
@export var ads_response: float = 20.0
@export var hip_position := Vector3(0.23, -0.22, -0.45)
@export var ads_position := Vector3(0.0, -0.12, -0.42)
@export var recoil_degrees: float = 1.2
@export var ads_recoil_multiplier: float = 0.55
@export var recoil_recovery: float = 12.0
@export var max_recoil_degrees: float = 4.0

var magazine: int = 0
var reserve: int = 0
var is_holstered: bool = false
var holster_amount: float = 0.0
var _holster_left: float = 0.0
var _pending_holster: bool = false
var _buffer_left: float = 0.0
var is_reloading: bool = false
var is_aiming: bool = false
var _input_enabled: bool = false
var _fire_armed: bool = false
var _aim_blocked: bool = true
var _pending_fire: bool = false
var _pending_reload: bool = false
var _cooldown: float = 0.0
var _reload_left: float = 0.0
var _flash_left: float = 0.0
var _recoil := Vector2.ZERO
var _kick: float = 0.0
var _shot_number: int = 0
var _query := PhysicsRayQueryParameters3D.new()

@onready var visuals: Node3D = $Visuals
@onready var muzzle_flash: MeshInstance3D = $Visuals/Muzzle/Flash

func configure_roster(profiles: Array[TestWeaponProfile], start: int, arms: bool) -> void:
	weapon_profiles = profiles
	active_weapon = start
	arms_requested = arms
	for profile: TestWeaponProfile in profiles:
		_ammunition.append(Vector2i(profile.magazine_capacity, profile.reserve))
		_inactive_cooldowns.append(0.0)
	placeholder_muzzle = get_node("Visuals/Muzzle").transform
	apply_test_profile(profiles[start])

func apply_test_profile(profile: TestWeaponProfile) -> void:
	# Profile data changes here; ammunition and transitions stay in this firearm.
	test_profile = profile
	magazine_capacity = profile.magazine_capacity
	starting_reserve = profile.reserve
	shot_interval = profile.shot_interval
	reload_duration = profile.reload_duration
	recoil_degrees = profile.recoil_degrees
	ads_fov = profile.ads_fov
	hip_position = profile.hip_position
	ads_position = profile.ads_position
	show_arms = arms_requested and profile == weapon_profiles[0]
	if show_arms:
		hip_position = Vector3(0.23, -0.22, -0.45)

func _ready() -> void:
	magazine = magazine_capacity
	reserve = starting_reserve
	position = hip_position
	_query.collision_mask = 3
	_query.exclude = [actor.get_rid()]
	_query.hit_from_inside = true
	muzzle_flash.visible = false
	actor.mouse_capture_changed.connect(set_input_enabled)
	aim_changed.connect(actor.set_aiming)
	set_input_enabled(actor.has_mouse_capture)

func set_input_enabled(value: bool) -> void:
	_input_enabled = value
	_pending_fire = false
	_pending_reload = false
	_pending_holster = false
	_pending_weapon = -1
	_buffer_left = 0.0
	_fire_armed = false
	_aim_blocked = true
	if not value:
		# Cancellation never transfers ammo; recapture is never a shot.
		is_reloading = false
		_reload_left = 0.0
		_set_aiming(false)
		status_changed.emit("")
		_recoil = Vector2.ZERO
		_kick = 0.0
		_flash_left = 0.0
		muzzle_flash.visible = false
		camera.rotation = Vector3.ZERO
		camera.fov = actor.field_of_view

func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	for index: int in range(weapon_profiles.size()):
		if event.is_action_pressed("weapon_%d" % (index + 1)):
			_pending_weapon = index
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("holster") and not event.is_echo():
		_pending_holster = true
		get_viewport().set_input_as_handled()
		return
	if event.is_action_released("fire"):
		_buffer_left = 0.0
	if not is_weapon_ready():
		return
	if event.is_action_released("aim"):
		_aim_blocked = false
		_set_aiming(false)
	elif event.is_action_pressed("aim") and not _aim_blocked:
		_set_aiming(not is_reloading)
	elif event.is_action_pressed("fire") and _fire_armed:
		_pending_fire = true
		_fire_armed = false
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("reload"):
		_pending_reload = true
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	for index: int in range(_inactive_cooldowns.size()):
		if index != active_weapon:
			_inactive_cooldowns[index] = maxf(0.0, _inactive_cooldowns[index] - delta)
	_holster_left = maxf(0.0, _holster_left - delta)
	_buffer_left = maxf(0.0, _buffer_left - delta)
	if not _input_enabled:
		return
	if _pending_weapon >= 0:
		var requested: int = _pending_weapon
		_pending_weapon = -1
		_switch_weapon(requested)
		return
	if _pending_holster:
		_pending_holster = false
		if _holster_left <= 0.0:
			is_holstered = not is_holstered
			_holster_left = holster_duration
			is_reloading = false
			_reload_left = 0.0
			_pending_fire = false
			_pending_reload = false
			_buffer_left = 0.0
			_fire_armed = false
			_aim_blocked = true
			_set_aiming(false)
			_flash_left = 0.0
			muzzle_flash.visible = false
			status_changed.emit("")
	if not is_weapon_ready():
		return
	if not Input.is_action_pressed("fire"):
		_fire_armed = true
		_buffer_left = 0.0
	if not Input.is_action_pressed("aim"):
		_aim_blocked = false
	if is_reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			var transferred: int = mini(magazine_capacity - magazine, reserve)
			magazine += transferred
			reserve -= transferred
			is_reloading = false
			ammunition_changed.emit(magazine, reserve)
			status_changed.emit("")
	if _pending_reload:
		_start_reload()
	_set_aiming(not _aim_blocked and Input.is_action_pressed("aim") and not is_reloading)
	if _pending_fire:
		if not is_reloading and _cooldown > 0.0 and _cooldown <= fire_buffer_window:
			_buffer_left = fire_buffer_window
		else:
			_try_fire()
	if _buffer_left > 0.0 and _cooldown <= 0.0 and Input.is_action_pressed("fire"):
		_buffer_left = 0.0
		_try_fire()
	_pending_fire = false
	_pending_reload = false

func _switch_weapon(index: int) -> void:
	if index == active_weapon:
		return
	_ammunition[active_weapon] = Vector2i(magazine, reserve)
	_inactive_cooldowns[active_weapon] = _cooldown
	# Cancel before changing data: reload never transfers ammo on a switch.
	set_input_enabled(false)
	active_weapon = index
	apply_test_profile(weapon_profiles[index])
	magazine = _ammunition[index].x
	reserve = _ammunition[index].y
	_cooldown = _inactive_cooldowns[index]
	is_holstered = false
	holster_amount = 1.0
	_holster_left = holster_duration
	position = hip_position
	visuals.transform = Transform3D.IDENTITY
	set_input_enabled(actor.has_mouse_capture)
	weapon_changed.emit(test_profile)
	ammunition_changed.emit(magazine, reserve)

func _process(delta: float) -> void:
	# Only presentation is interpolated: raw mouse input and shot requests are not.
	holster_amount = move_toward(holster_amount, 1.0 if is_holstered else 0.0, delta / holster_duration)
	var blend: float = 1.0 - exp(-ads_response * delta)
	position = position.lerp(ads_position if is_aiming else hip_position, blend)
	camera.fov = lerpf(camera.fov, minf(ads_fov, actor.field_of_view) if is_aiming else actor.field_of_view, blend)
	_recoil *= exp(-recoil_recovery * delta)
	_kick *= exp(-18.0 * delta)
	_apply_recoil()
	visuals.position.z = _kick
	visuals.rotation.x = _kick * 1.5
	visuals.rotation.z = lerpf(visuals.rotation.z, -0.15 if is_reloading else 0.0, blend)
	_flash_left = maxf(0.0, _flash_left - delta)
	muzzle_flash.visible = _flash_left > 0.0

func get_reload_progress() -> float:
	return clampf(1.0 - _reload_left / reload_duration, 0.0, 1.0) if is_reloading else 0.0

func is_weapon_ready() -> bool:
	return not is_holstered and _holster_left <= 0.0 and holster_amount <= 0.001

func _set_aiming(value: bool) -> void:
	if is_aiming != value:
		is_aiming = value
		aim_changed.emit(value)

func _start_reload() -> void:
	if not is_weapon_ready() or is_reloading or magazine >= magazine_capacity or reserve <= 0:
		return
	_buffer_left = 0.0
	is_reloading = true
	_reload_left = reload_duration
	status_changed.emit("Nachladen …")

func _try_fire() -> void:
	if not is_weapon_ready() or is_reloading or _cooldown > 0.0:
		return
	if magazine <= 0:
		status_changed.emit("Leer · R" if reserve > 0 else "Keine Munition")
		return
	# Query the exact current crosshair direction BEFORE adding this shot's kick.
	_query.from = camera.global_position
	var direction: Vector3 = -camera.global_basis.z
	_query.to = _query.from + direction * shot_range
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(_query)
	magazine -= 1
	_cooldown = shot_interval
	status_changed.emit("")
	ammunition_changed.emit(magazine, reserve)
	if not hit.is_empty():
		var collider := hit["collider"] as Node
		var confirmed: bool = false
		if collider is RigidBody3D:
			var body := collider as RigidBody3D
			body.apply_impulse(direction * impulse_strength, (hit["position"] as Vector3) - body.global_position)
			confirmed = true
		if collider.has_method("receive_hit"):
			collider.call("receive_hit", damage)
			confirmed = true
		if confirmed:
			hit_confirmed.emit()
	_shot_number += 1
	var strength: float = ads_recoil_multiplier if is_aiming else 1.0
	_recoil.x = minf(_recoil.x + deg_to_rad(recoil_degrees) * strength, deg_to_rad(max_recoil_degrees))
	_recoil.y += deg_to_rad(0.12) * strength * (1.0 if _shot_number % 2 == 0 else -1.0)
	_kick = 0.035 * strength
	_flash_left = 0.035
	_apply_recoil()
	fired.emit()

func _apply_recoil() -> void:
	var pitch: float = minf(_recoil.x, deg_to_rad(89.0) - actor.head.rotation.x)
	camera.rotation = Vector3(pitch, _recoil.y, 0.0)

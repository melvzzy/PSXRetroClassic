class_name TestWeaponProfile
extends Resource
## Immutable weapon tuning; live ammo and switching belong to TestFirearm.
@export var display_name: String = "Makarov"
@export var model: PackedScene
@export var magazine_capacity: int = 12
@export var reserve: int = 48
@export var automatic_fire: bool = false
@export var ads_response: float = 20.0
@export var recoil_recovery: float = 12.0
@export var max_recoil_degrees: float = 4.0
@export var shot_interval: float = 0.18
@export var reload_duration: float = 1.35
@export var recoil_degrees: float = 1.2
@export var ads_fov: float = 60.0
@export var hip_position := Vector3(0.23, -0.165, -0.45)
@export var hip_rotation_degrees := Vector3.ZERO
@export var sprint_offset := Vector3(0.025, -0.065, 0.045)
@export var sprint_rotation_degrees := Vector3(8.0, 12.0, -12.0)
@export var visual_kick: float = 0.025
@export var visual_recovery: float = 18.0
@export var ads_position := Vector3(0.0, -0.12, -0.42)
@export var moving_parts: PackedStringArray = []
@export var part_travel: float = 0.018
@export var hidden_parts: PackedStringArray = []

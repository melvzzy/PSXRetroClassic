extends Node3D

@onready var prompt: Label = $HUD/Prompt
@onready var weapon: TestFirearm = $Player/Head/Camera3D/ViewmodelMount/TestFirearm
var _hit_marker_left: float = 0.0

func _ready() -> void:
	$Player/Head/Camera3D/Interactor.prompt_changed.connect(_on_prompt_changed)
	$HUD/Quit.pressed.connect(_quit)
	$Player.mouse_capture_changed.connect(_on_mouse_capture_changed)
	_on_mouse_capture_changed($Player.has_mouse_capture)
	weapon.ammunition_changed.connect(_on_ammunition_changed)
	weapon.status_changed.connect(_on_weapon_status_changed)
	weapon.hit_confirmed.connect(_on_hit_confirmed)
	_on_ammunition_changed(weapon.magazine, weapon.reserve)

func _on_mouse_capture_changed(captured: bool) -> void:
	$HUD/Help.visible = not captured
	$HUD/Quit.visible = not captured
	$HUD/Crosshair.visible = captured
	$HUD/Ammo.visible = captured
	$HUD/WeaponStatus.visible = captured
	if not captured:
		_hit_marker_left = 0.0
		$HUD/HitMarker.visible = false

func _process(delta: float) -> void:
	var captured: bool = $Player.has_mouse_capture
	$HUD/Crosshair.visible = captured and not weapon.is_aiming and weapon.is_weapon_ready()
	$HUD/Ammo.visible = captured and not weapon.is_holstered
	_hit_marker_left = maxf(0.0, _hit_marker_left - delta)
	$HUD/HitMarker.visible = _hit_marker_left > 0.0

func _on_ammunition_changed(magazine: int, reserve: int) -> void:
	$HUD/Ammo.text = "%d / %d" % [magazine, reserve]

func _on_weapon_status_changed(text: String) -> void:
	$HUD/WeaponStatus.text = text

func _on_hit_confirmed() -> void:
	_hit_marker_left = 0.1

func _on_prompt_changed(text: String) -> void:
	prompt.text = text

func _quit() -> void:
	get_tree().quit()

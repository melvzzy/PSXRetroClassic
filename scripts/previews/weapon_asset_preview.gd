extends Node3D
## Selection is confined to this asset viewer; no in-game weapon switching.
const MODELS: Array[PackedScene] = [
	preload("res://scenes/weapons/makarov.tscn"),
	preload("res://scenes/weapons/as_val.tscn"),
	preload("res://scenes/weapons/vss.tscn"),
	preload("res://scenes/weapons/sr3.tscn"),
	preload("res://scenes/weapons/izh54.tscn"),
]
const NAMES: PackedStringArray = ["Makarov · in-game pistol", "AS Val · preview only", "VSS · preview only", "SR-3 · preview only", "Izh-54 · preview only"]
var model: WeaponAsset
var _rest: Dictionary[StringName, Transform3D] = {}
var _animations: AnimationPlayer
var _visibility: Dictionary[StringName, bool] = {}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Camera.look_at(Vector3(-0.2, 1.25, 0))
	var arms_player: AnimationPlayer = $ArmsReference/Arms.find_child("AnimationPlayer", true, false)
	arms_player.play("guard_idle")
	arms_player.seek(0.4, true)
	arms_player.pause()
	for name: String in NAMES:
		$HUD/Panel/Weapon.add_item(name)
	$HUD/Panel/Weapon.item_selected.connect(select_weapon)
	$HUD/Panel/Part.item_selected.connect(_select_part)
	$HUD/Panel/Offset.value_changed.connect(_move_part)
	$HUD/Panel/Yaw.value_changed.connect(func(value: float) -> void: $Stage.rotation.y = deg_to_rad(value))
	$HUD/Panel/Zoom.value_changed.connect(_zoom)
	$HUD/Panel/ArmsVisible.toggled.connect(func(value: bool) -> void: $ArmsReference.visible = value)
	$HUD/Panel/PlayClip.pressed.connect(_play_clip)
	$HUD/Panel/Close.pressed.connect(func() -> void: get_tree().quit())
	select_weapon(0)
	_zoom($HUD/Panel/Zoom.value)

func select_weapon(index: int) -> void:
	if model != null:
		$Stage.remove_child(model)
		model.queue_free()
	model = MODELS[index].instantiate() as WeaponAsset
	$Stage.add_child(model)
	$Stage.rotation.y = 0.0
	$HUD/Panel/Yaw.set_value_no_signal(0.0)
	_rest.clear()
	_visibility.clear()
	$HUD/Panel/Part.clear()
	for name: StringName in model.parts:
		_rest[name] = model.parts[name].transform
		_visibility[name] = model.parts[name].visible
		$HUD/Panel/Part.add_item(name)
	_animations = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	$HUD/Panel/Clip.clear()
	var usable: int = 0
	if _animations != null:
		for clip: StringName in _animations.get_animation_list():
			var animation: Animation = _animations.get_animation(clip)
			$HUD/Panel/Clip.add_item("%s · %d tracks" % [clip, animation.get_track_count()])
			$HUD/Panel/Clip.set_item_metadata($HUD/Panel/Clip.item_count - 1, clip)
			usable += int(animation.get_track_count() > 0)
	$HUD/Panel/PlayClip.disabled = usable == 0
	$HUD/Panel/Info.text = "%d separate parts · meter-normalized\n%s\nArms: reference pose, not retargeted.\nPart offset is inspection, not a reload clip." % [model.parts.size(), "No usable supplied weapon clips." if usable == 0 else "Source clips available: inspect before use."]
	_select_part(0)

func _select_part(_index: int) -> void:
	for name: StringName in _rest:
		model.parts[name].transform = _rest[name]
		model.parts[name].visible = _visibility[name]
	var selected: StringName = $HUD/Panel/Part.get_item_text($HUD/Panel/Part.selected)
	model.parts[selected].visible = true
	if selected == &"Magazine-Empty":
		model.get_part("Magazine-Full").visible = false
	$HUD/Panel/Offset.set_value_no_signal(0.0)

func _move_part(value: float) -> void:
	var name: StringName = $HUD/Panel/Part.get_item_text($HUD/Panel/Part.selected)
	var part: Node3D = model.get_part(name)
	part.transform = _rest[name]
	# Parent FBX units are normalized by Source. Move a visible 10 cm vertically.
	part.position.y += value * 0.1 / model.get_node("Source").scale.y

func _play_clip() -> void:
	if _animations != null and $HUD/Panel/Clip.selected >= 0:
		_animations.play($HUD/Panel/Clip.get_item_metadata($HUD/Panel/Clip.selected))

func _zoom(distance: float) -> void:
	var target := Vector3(0.3, 1.2, 0)
	$Camera.position = target + Vector3(1, 0.35, 1.4).normalized() * distance
	$Camera.look_at(target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

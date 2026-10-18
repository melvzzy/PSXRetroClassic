extends Node3D
## Isolated asset inspection only: no player, weapon logic, retargeting or IK.
const BARE: Texture2D = preload("res://assets/source/drillimpact_first_person_arms/arms_01.png")
const GLOVES: Texture2D = preload("res://assets/source/drillimpact_first_person_arms/arms_gloves_01.png")

var animation_player: AnimationPlayer
var skeleton: Skeleton3D
var mesh: MeshInstance3D
var preview_material: StandardMaterial3D
var _scrubbing: bool = false
var _clip_length: float = 0.0
var _last_position: float = 0.0

@onready var clips: OptionButton = $HUD/Panel/Clip
@onready var scrub: HSlider = $HUD/Panel/Scrub
@onready var info: Label = $HUD/Panel/Info

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	animation_player = $Orientation/Arms.find_child("AnimationPlayer", true, false) as AnimationPlayer
	skeleton = $Orientation/Arms.find_child("Skeleton3D", true, false) as Skeleton3D
	mesh = $Orientation/Arms.find_child("ArmsMesh", true, false) as MeshInstance3D
	assert(animation_player != null and skeleton != null and mesh != null, "Unexpected imported arms hierarchy")
	preview_material = (mesh.get_active_material(0) as StandardMaterial3D).duplicate()
	preview_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	mesh.set_surface_override_material(0, preview_material)
	for clip: StringName in animation_player.get_animation_list():
		if clip != &"RESET":
			clips.add_item(clip)
	clips.item_selected.connect(play_clip)
	$HUD/Panel/Playback/PlayPause.pressed.connect(_toggle_playback)
	$HUD/Panel/Playback/Restart.pressed.connect(func() -> void: play_clip(clips.selected))
	animation_player.animation_finished.connect(_on_finished)
	scrub.drag_started.connect(func() -> void: _scrubbing = true)
	scrub.drag_ended.connect(func(_changed: bool) -> void: _scrubbing = false)
	scrub.value_changed.connect(_seek)
	var textures: OptionButton = $HUD/Panel/Texture
	textures.add_item("Bare hands · 512 × 512")
	textures.add_item("Black gloves · 512 × 512")
	textures.item_selected.connect(set_texture)
	var views: OptionButton = $HUD/Panel/View
	views.add_item("First person · FOV 80°")
	views.add_item("Overview · original meter scale")
	views.item_selected.connect(set_view)
	$Overview.look_at(Vector3(0, 1.4, -0.2))
	$HUD/Panel/Quit.pressed.connect(func() -> void: get_tree().quit())
	set_texture(0)
	var initial: int = 0
	for index: int in range(clips.item_count):
		if clips.get_item_text(index) == "guard_idle":
			initial = index
	clips.select(initial)
	play_clip(initial)

func play_clip(index: int) -> void:
	clips.select(index)
	_clip_length = animation_player.get_animation(clips.get_item_text(index)).length
	_last_position = 0.0
	animation_player.play(clips.get_item_text(index))
	animation_player.seek(0.0, true)
	$HUD/Panel/Playback/PlayPause.text = "Pause"

func set_texture(index: int) -> void:
	$HUD/Panel/Texture.select(index)
	preview_material.albedo_texture = BARE if index == 0 else GLOVES

func set_view(index: int) -> void:
	$HUD/Panel/View.select(index)
	if index == 0:
		$FirstPerson.make_current()
	else:
		$Overview.make_current()

func _toggle_playback() -> void:
	if animation_player.is_playing():
		animation_player.pause()
		$HUD/Panel/Playback/PlayPause.text = "Play"
	else:
		if animation_player.current_animation.is_empty():
			play_clip(clips.selected)
		else:
			animation_player.play()
		$HUD/Panel/Playback/PlayPause.text = "Pause"

func _on_finished(_clip: StringName) -> void:
	_last_position = _clip_length
	if $HUD/Panel/Playback/Repeat.button_pressed:
		play_clip(clips.selected)
	else:
		$HUD/Panel/Playback/PlayPause.text = "Play"

func _seek(value: float) -> void:
	if _scrubbing:
		if animation_player.current_animation.is_empty():
			animation_player.play(clips.get_item_text(clips.selected))
			animation_player.pause()
		_last_position = value * _clip_length
		animation_player.seek(_last_position, true)

func _process(_delta: float) -> void:
	if not animation_player.current_animation.is_empty():
		_last_position = animation_player.current_animation_position
	if not _scrubbing:
		scrub.set_value_no_signal(_last_position / maxf(_clip_length, 0.001))
	info.text = "%d bones · 1 m = 1 unit\n%.2f / %.2f s · Esc closes preview" % [skeleton.get_bone_count(), _last_position, _clip_length]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

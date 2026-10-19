extends Node3D
## Isolated asset inspection only; never instanced by the playable Startup.
const SOURCES: Array[String] = [
	"res://assets/source/character_candidates/simple_character_psx/original/simple-character-psx.glb",
	"res://assets/source/character_candidates/male_casual/original/male_casual.fbx",
]
const TEXTURES: Array[String] = [
	"res://assets/source/character_candidates/simple_character_psx/original/character_256.png",
	"res://assets/source/character_candidates/male_casual/original/man_tex.png",
]
var models: Array[Node3D] = []
var skeletons: Array[Skeleton3D] = []
var audits: Array[Dictionary] = []
var probe_enabled: bool = false
var _rest_poses: Array[Dictionary] = []
var _yaw: float = 0.0
var _pitch: float = 0.0
var _distance: float = 5.0
var _target := Vector3(0.0, 0.95, 0.0)
var _dragging: bool = false
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	for index: int in range(2):
		_load_character(index)
	set_view(0)

func _load_character(index: int) -> void:
	if not FileAccess.file_exists(SOURCES[index]):
		models.append(null)
		skeletons.append(null)
		audits.append({"missing": true})
		_rest_poses.append({})
		$HUD/Info.text += "\n%s: lokale Quelldatei fehlt; siehe Asset-README." % ("Simple PSX" if index == 0 else "male_casual")
		return
	var mount: Node3D = get_node("SimpleMount" if index == 0 else "MaleMount")
	var calibration := Node3D.new()
	calibration.name = "Calibration"
	mount.add_child(calibration)
	var model: Node3D = load(SOURCES[index]).instantiate()
	calibration.add_child(model)
	models.append(model)
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false)
	skeletons.append(skeleton)
	var texture: Texture2D = load(TEXTURES[index])
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		for surface: int in range(mesh.mesh.get_surface_count()):
			var original: StandardMaterial3D = mesh.get_active_material(surface)
			var material: StandardMaterial3D = original.duplicate() if original else StandardMaterial3D.new()
			# Keep the separate glasses lens material; texture the opaque character surfaces.
			if material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED:
				material.albedo_texture = texture
				material.roughness = 0.9
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
			mesh.set_surface_override_material(surface, material)
	var data: Dictionary = inspect_model(model)
	audits.append(data)
	var box: AABB = data.bounds
	var scale_factor: float = 1.8 / box.size.y
	calibration.scale = Vector3.ONE * scale_factor
	calibration.position = -Vector3(box.get_center().x, box.position.y, box.get_center().z) * scale_factor
	mount.rotation.y = PI
	var poses: Dictionary = {}
	for bone: int in range(skeleton.get_bone_count()):
		poses[bone] = skeleton.get_bone_pose_rotation(bone)
	_rest_poses.append(poses)

static func inspect_model(model: Node3D) -> Dictionary:
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false)
	var bounds := AABB()
	var first: bool = true
	var weights: Dictionary = {}
	var triangles: int = 0
	var invalid_weights: int = 0
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		for surface: int in range(mesh.mesh.get_surface_count()):
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			triangles += indices.size() / 3 if not indices.is_empty() else vertices.size() / 3
			var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
			var influences: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			var per_vertex: int = bones.size() / vertices.size() if not vertices.is_empty() else 0
			for vertex: int in range(vertices.size()):
				var point := Vector3.ZERO
				var total: float = 0.0
				for slot: int in range(per_vertex):
					var offset: int = vertex * per_vertex + slot
					var weight: float = influences[offset]
					if weight <= 0.00001:
						continue
					var bind: int = bones[offset]
					var name: StringName = mesh.skin.get_bind_name(bind)
					var bone: int = skeleton.find_bone(name)
					if bone < 0:
						invalid_weights += 1
						continue
					weights[str(name)] = int(weights.get(str(name), 0)) + 1
					point += (model.global_transform.affine_inverse() * skeleton.global_transform * skeleton.get_bone_global_pose(bone) * mesh.skin.get_bind_pose(bind) * vertices[vertex]) * weight
					total += weight
				if total <= 0.0:
					invalid_weights += 1
				else:
					point /= total
				bounds = AABB(point, Vector3.ZERO) if first else bounds.expand(point)
				first = false
	var names: Array[String] = []
	for bone: int in range(skeleton.get_bone_count()):
		names.append(skeleton.get_bone_name(bone))
	var clips: Array[String] = []
	for player: AnimationPlayer in model.find_children("*", "AnimationPlayer", true, false):
		for clip: StringName in player.get_animation_list():
			if clip != &"RESET":
				clips.append(str(clip))
	return {"bounds": bounds, "bones": names, "triangles": triangles, "weighted_bones": weights, "invalid_weights": invalid_weights, "clips": clips}

func set_probe(enabled: bool) -> void:
	probe_enabled = enabled
	for index: int in range(skeletons.size()):
		var skeleton: Skeleton3D = skeletons[index]
		if skeleton == null:
			continue
		for bone: int in _rest_poses[index]:
			var turn: Quaternion = _rest_poses[index][bone]
			var title: String = skeleton.get_bone_name(bone)
			if enabled and (title.begins_with("f_index.02") or title.begins_with("f_middle.01")):
				turn *= Quaternion(Vector3.RIGHT, 0.5)
			skeleton.set_bone_pose_rotation(bone, turn)
	$HUD/Probe.text = "B: lokale Fingergelenk-Probe AN (kein Clip)" if enabled else "B: lokale Fingergelenk-Probe AUS · Quellpose"

func set_view(index: int) -> void:
	_yaw = 0.0
	_pitch = 0.0
	_distance = 5.0 if index == 0 else 2.8
	var selected: int = 0 if index in [1,3] else 1
	_target = Vector3(0, 0.95, 0) if index == 0 else get_node("SimpleMount" if selected == 0 else "MaleMount").position + Vector3.UP * 0.95
	for model_index: int in range(models.size()):
		if models[model_index] != null:
			models[model_index].visible = index == 0 or model_index == selected
	$SimpleLabel.visible = index in [0,1]
	$MaleLabel.visible = index in [0,2]
	if index >= 3:
		var character: int = 0 if index == 3 else 1
		var skeleton: Skeleton3D = skeletons[character]
		if skeleton != null:
			var bone: int = skeleton.find_bone("hand.R" if character == 0 else "hand_right")
			var hand: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone)
			_target = hand.origin + hand.basis.y.normalized() * 0.06
			_distance = 0.4
			_yaw = -0.6
			_pitch = -0.3
	_update_camera()

func _update_camera() -> void:
	camera.position = _target + Vector3(sin(_yaw) * cos(_pitch), sin(_pitch), -cos(_yaw) * cos(_pitch)) * _distance
	camera.look_at(_target)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_0 and event.physical_keycode <= KEY_4:
			set_view(event.physical_keycode - KEY_0)
		elif event.physical_keycode == KEY_B:
			set_probe(not probe_enabled)
		elif event.physical_keycode == KEY_ESCAPE:
			get_tree().quit()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			_distance = clampf(_distance * (0.88 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.12), 0.18, 8.0)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		_yaw -= event.relative.x * 0.008
		_pitch = clampf(_pitch + event.relative.y * 0.008, -1.3, 1.3)
		_update_camera()

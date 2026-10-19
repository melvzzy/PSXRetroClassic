class_name WeaponAsset
extends Node3D
## Visual-only import wrapper. No ammunition, input or firing behavior.
@export var albedo: Texture2D
@export var hidden_parts: PackedStringArray = []
var parts: Dictionary[StringName, Node3D] = {}

func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_texture = albedo
	material.roughness = 0.85
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	for node: Node in $Source.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		parts[mesh.name] = mesh
		mesh.material_override = material
		mesh.visible = not hidden_parts.has(mesh.name)

func get_part(part_name: StringName) -> Node3D:
	return parts.get(part_name) as Node3D

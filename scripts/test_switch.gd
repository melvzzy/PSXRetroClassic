extends StaticBody3D

var active: bool = false
@onready var indicator: MeshInstance3D = $Indicator
@onready var status: Label3D = $Status

func _ready() -> void:
	indicator.material_override = indicator.material_override.duplicate()
	$InteractionTarget.interacted.connect(_on_interacted)

func _on_interacted(_actor: Node3D) -> void:
	active = not active
	(indicator.material_override as StandardMaterial3D).albedo_color = Color(0.25, 0.8, 0.4) if active else Color(0.5, 0.5, 0.5)
	status.text = "Schalter: AN" if active else "Schalter: AUS"

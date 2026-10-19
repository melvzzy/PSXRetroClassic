extends StaticBody3D

@export var controlled_light: OmniLight3D
var active: bool = false
@onready var indicator: MeshInstance3D = $Indicator
@onready var status: Label3D = $Status

func _ready() -> void:
	indicator.material_override = indicator.material_override.duplicate()
	$InteractionTarget.interacted.connect(_on_interacted)
	_update_feedback()

func _on_interacted(_actor: Node3D) -> void:
	active = not active
	_update_feedback()

func _update_feedback() -> void:
	if controlled_light != null:
		controlled_light.light_energy = 1.0 if active else 0.15
		$InteractionTarget.prompt = "E — Werkstattlicht ausschalten" if active else "E — Werkstattlicht einschalten"
	(indicator.material_override as StandardMaterial3D).albedo_color = Color(0.25, 0.8, 0.4) if active else Color(0.5, 0.5, 0.5)
	status.text = "Schalter: AN" if active else "Schalter: AUS"

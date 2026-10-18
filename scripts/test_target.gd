extends StaticBody3D
## Non-destructible calibration target; deliberately no enemy/health framework.
var hit_count: int = 0
var total_damage: float = 0.0
var _feedback_left: float = 0.0
@onready var face: MeshInstance3D = $Face
@onready var label: Label3D = $Label

func _ready() -> void:
	face.material_override = face.material_override.duplicate()

func receive_hit(damage: float) -> void:
	hit_count += 1
	total_damage += damage
	_feedback_left = 0.12
	label.text = "Treffer: %d" % hit_count
	(face.material_override as StandardMaterial3D).albedo_color = Color(0.85, 0.85, 0.85)

func _process(delta: float) -> void:
	if _feedback_left > 0.0:
		_feedback_left -= delta
		if _feedback_left <= 0.0:
			(face.material_override as StandardMaterial3D).albedo_color = Color(0.3, 0.3, 0.3)

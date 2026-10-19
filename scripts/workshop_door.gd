extends Node3D
## One physics-driven sliding door. World layout and firearm state stay independent.
@export_range(0.2, 4.0) var travel_speed: float = 1.8
@export var starts_open: bool = true

const TRAVEL: float = -2.85
var is_open: bool = true
var _query := PhysicsShapeQueryParameters3D.new()
@onready var panel: AnimatableBody3D = $Panel
@onready var target: InteractionTarget = $Control/InteractionTarget
@onready var status: Label3D = $Control/Status

func _ready() -> void:
	is_open = starts_open
	panel.position.x = TRAVEL if is_open else 0.0
	_query.shape = $Panel/Collision.shape
	_query.collision_mask = 6 # Player and dynamic props; exclude the static frame.
	_query.margin = 0.0
	_query.exclude = [panel.get_rid()]
	target.interacted.connect(_on_interacted)
	$Panel/InteractionTarget.interacted.connect(_on_interacted)
	_update_feedback()
	set_physics_process(false)

func _on_interacted(_actor: Node3D) -> void:
	is_open = not is_open
	_update_feedback()
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var next_x: float = move_toward(panel.position.x, TRAVEL if is_open else 0.0, travel_speed * delta)
	var motion := Vector3(next_x - panel.position.x, 0.0, 0.0)
	_query.transform = $Panel/Collision.global_transform
	_query.motion = motion
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var fractions: PackedFloat32Array = space.cast_motion(_query)
	if not space.intersect_shape(_query, 1).is_empty() or fractions[0] < 1.0:
		# Never crush, shove or repeatedly retry against a player or loose prop.
		if not is_open:
			is_open = true
			_update_feedback()
			status.text = "Durchgang blockiert — öffnet"
		else:
			status.text = "Tor blockiert"
			set_physics_process(false)
		return
	panel.position.x = next_x
	if is_equal_approx(next_x, TRAVEL if is_open else 0.0):
		_update_feedback()
		set_physics_process(false)

func _update_feedback() -> void:
	var text: String = "E — Werkstatttor schließen" if is_open else "E — Werkstatttor öffnen"
	target.prompt = text
	$Panel/InteractionTarget.prompt = text
	status.text = "WERKSTATT — OFFEN" if is_open else "WERKSTATT — ZU"


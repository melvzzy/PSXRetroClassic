class_name Interactor
extends RayCast3D

signal prompt_changed(text: String)

@export_range(0.1, 5.0) var interaction_range: float = 2.5
@export var actor: Node3D

var _target: InteractionTarget
var _last_prompt: String = ""
var _input_enabled: bool = false

func _ready() -> void:
	if actor is CollisionObject3D:
		add_exception(actor as CollisionObject3D)
	enabled = true
	target_position = Vector3(0.0, 0.0, -interaction_range)

func _physics_process(_delta: float) -> void:
	_target = null
	if _input_enabled:
		target_position.z = -interaction_range
		force_raycast_update()
		var collider := get_collider() as Node
		if collider != null:
			_target = collider.get_node_or_null("InteractionTarget") as InteractionTarget
		if _target != null and not _target.enabled:
			_target = null
	var text: String = _target.prompt if _target != null else ""
	if text != _last_prompt:
		_last_prompt = text
		prompt_changed.emit(text)
	if _target != null and Input.is_action_just_pressed("interact"):
		_target.interact(actor)

func set_input_enabled(value: bool) -> void:
	_input_enabled = value

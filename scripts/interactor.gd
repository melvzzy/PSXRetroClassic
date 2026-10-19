class_name Interactor
extends RayCast3D

signal prompt_changed(text: String)

@export_range(0.1, 5.0) var interaction_range: float = 2.5
@export var actor: Node3D

var _target: InteractionTarget
var _last_prompt: String = ""
var _input_enabled: bool = false
var _interaction_requested: bool = false
var _request_query := PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	if actor is CollisionObject3D:
		add_exception(actor as CollisionObject3D)
	_request_query.exclude = [actor.get_rid()] if actor is CollisionObject3D else []
	# Manual updates below already run after player movement; avoid a duplicate automatic query.
	enabled = false
	target_position = Vector3(0.0, 0.0, -interaction_range)

func _physics_process(_delta: float) -> void:
	var requested: bool = _interaction_requested
	_interaction_requested = false
	_target = null
	if _input_enabled:
		target_position.z = -interaction_range
		force_raycast_update()
		var collider := get_collider() as Node
		if collider != null:
			_target = collider.get_node_or_null("InteractionTarget") as InteractionTarget
		if _target != null and not _target.enabled:
			_target = null
	# Resolve the press-time ray in physics, including an aim change just before E.
	# Both rays must still identify the same object; turning away cancels use.
	if requested and is_instance_valid(_target):
		_request_query.collision_mask = collision_mask
		var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(_request_query)
		if hit.get("collider") == get_collider():
			_target.interact(actor)
	var text: String = _target.prompt if is_instance_valid(_target) and _target.enabled else ""
	if text != _last_prompt:
		_last_prompt = text
		prompt_changed.emit(text)

func _unhandled_input(event: InputEvent) -> void:
	if _input_enabled and event.is_action_pressed("interact") and not event.is_echo():
		_interaction_requested = true
		_request_query.from = global_position
		_request_query.to = global_position - global_basis.z * interaction_range
		get_viewport().set_input_as_handled()

func set_input_enabled(value: bool) -> void:
	_input_enabled = value
	_interaction_requested = false
	if not value:
		_target = null
		if not _last_prompt.is_empty():
			_last_prompt = ""
			prompt_changed.emit("")

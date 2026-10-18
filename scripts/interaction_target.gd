class_name InteractionTarget
extends Node
## Add as a direct child named InteractionTarget on a physics collider.
## Connect interacted to the object's behavior. No inventory or object registry.
signal interacted(actor: Node3D)

@export var prompt: String = "E — Interagieren"
@export var enabled: bool = true

func interact(actor: Node3D) -> void:
	if enabled:
		interacted.emit(actor)

@tool
extends Node3D

@export var enabled = true
@export var stretch_to: Node3D

func _process(delta: float) -> void:
	if enabled:
		look_at(stretch_to.position, Vector3.UP)
		scale.z = stretch_to.position.distance_to(global_position) * 100

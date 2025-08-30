class_name Gaze
extends RayCast3D

# Pokes other nodes to tell them they're being peeped

var target: Node

func _process(_delta: float) -> void:
	var other = get_collider()

	if other == null:
		if target and target.has_method("end_gaze"):
			target.end_gaze()
		target = null
		return

	if other is CollisionObject3D:
		var o: Node = other.get_parent().get_parent()
		# collider -> physics body -> actual node

		if target != o:
			# different target to last frame
			if target and target.has_method("end_gaze"):
				target.end_gaze()

			if o.has_method("begin_gaze"):
				o.begin_gaze()

			target = o
		else:
			# same target as last frame
			if o.has_method("gaze"):
				o.gaze()

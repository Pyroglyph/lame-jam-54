class_name Lever
extends Node3D

@export var rotation_axis := Vector3(0., 0., 1.)
@export var maximum_rotation := 45.

var value := 0.5

var forwards := true

var is_active := false

func set_value(v: float) -> void:
	value = clampf(v, 0, 1)
	rotation = Vector3.ZERO
	rotate_object_local(rotation_axis, deg_to_rad(lerpf(-maximum_rotation, maximum_rotation, value)))
	# DEBUG
	$"../Label3D".text = "%.2f" % value

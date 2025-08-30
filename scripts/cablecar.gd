extends Node3D

@export var from := Vector3.ZERO
@export var to := Vector3.ZERO
@export var time := 30.

@export var sway_max_degrees := 10

var tween: Tween

func _ready() -> void:
	position = from
	look_at(to, Vector3.UP)
	rotation.x = 0.
	rotation.z = 0.

	rotation.z = deg_to_rad(sway_max_degrees)

	tween = get_tree().create_tween()
	tween.tween_property(self, "position", to, time).set_ease(Tween.EASE_IN)

	sway()

func sway() -> void:
	tween = get_tree().create_tween().set_loops()
	tween.tween_property(self, "rotation:z", deg_to_rad(-sway_max_degrees), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation:z", deg_to_rad(sway_max_degrees), 2.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

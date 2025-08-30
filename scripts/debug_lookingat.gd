extends Label

var gaze: Gaze;

func _ready() -> void:
	gaze = get_viewport().get_camera_3d().find_child("Gaze")

func _process(delta: float) -> void:
	if gaze and gaze.target:
		text = str(gaze.target.get_path())
	else:
		text = "Nothing"

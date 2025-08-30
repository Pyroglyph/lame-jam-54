extends MeshInstance3D

@export var unscrew_direction := Vector3.UP
@export var unscrew_distance := 0.05
@export var sound: AudioStream

var stream_player: AudioStreamPlayer3D

func begin_use(player: Player) -> void:
	# play a sound, if one is set
	if sound:
		stream_player = AudioStreamPlayer3D.new()
		add_child(stream_player)
		stream_player.stream = sound
		stream_player.play()

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + unscrew_direction * unscrew_distance, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", rotation.rotated(unscrew_direction, -TAU), 0.2).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(wait_free)

func wait_free() -> void:
	if stream_player and stream_player.playing:
		stream_player.finished.connect(wait_free)
		return

	queue_free()

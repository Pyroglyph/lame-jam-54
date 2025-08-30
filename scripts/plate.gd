extends MeshInstance3D

@export var sound: AudioStream
@export var fail_sound: AudioStream # played when player tries to remove the plate while it's still screwed in

var stream_player: AudioStreamPlayer3D
var remove_direction := Vector3.DOWN
var remove_distance := 0.1

var can_use = true

func begin_use(player: Player) -> void:
	if not can_use:
		return

	can_use = false

	var screws = get_parent().find_children("Screw_*")
	if screws.size() > 0:
		# play failure sound, if one is set
		if fail_sound:
			var fail_stream_player = AudioStreamPlayer3D.new()
			add_child(fail_stream_player)
			fail_stream_player.stream = fail_sound
			fail_stream_player.play()
			fail_stream_player.finished.connect(fail_stream_player.queue_free)

		var original_position = position
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", original_position + remove_direction * 0.001, 0.05)
		tween.tween_property(self, "position", original_position - remove_direction * 0.001, 0.05)
		tween.tween_property(self, "position", original_position + remove_direction * 0.001, 0.05)
		tween.tween_property(self, "position", original_position - remove_direction * 0.001, 0.05)
		tween.tween_property(self, "position", original_position, 0.05)
		tween.tween_callback(func(): can_use = true)
		return

	remove()

func remove() -> void:
	$StaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED

	# play a sound, if one is set
	if sound:
		stream_player = AudioStreamPlayer3D.new()
		add_child(stream_player)
		stream_player.stream = sound
		stream_player.play()
		stream_player.finished.connect(wait_free)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + remove_direction * remove_distance, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", Vector3.FORWARD, 0.2).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector3.ZERO, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(wait_free)

func wait_free() -> void:
	if stream_player and stream_player.playing:
		stream_player.finished.connect(wait_free)
		return

	queue_free()

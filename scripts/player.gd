class_name Player
extends CharacterBody3D

@export var acceleration := 50.
@export var max_speed := 2.
@export var jump_force := 3.
@export var mouse_sensitivity := 0.001
@export var controller_sensitivity := 0.03

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var gravity_dir = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@onready var original_height = ($CollisionShape3D.shape as CylinderShape3D).height
@onready var crouch_height = original_height * 0.6

@onready var gaze: Gaze = $Camera3D/Gaze

var using = null
var disable_movement = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Local-space
var desired_vel := Vector3.ZERO
var wants_jump := false
var wants_crouch := false

func _process(delta: float) -> void:
	if not disable_movement:
		process_input(delta)

	if gaze.target:
		if Input.is_action_just_pressed("use"):
			if gaze.target.has_method("begin_use"):
				gaze.target.begin_use(self)
			using = gaze.target
	if using and Input.is_action_pressed("use"):
		if using.has_method("use"):
			using.use(self)
	if using and Input.is_action_just_released("use"):
		if using and using.has_method("end_use"):
			using.end_use(self)
		using = null

func _physics_process(delta: float) -> void:
	# Apply desired physics that we accumulated during _process

	# DEBUG: Reset
	if Input.is_key_pressed(KEY_R):
		position = Vector3.ZERO
		desired_vel = Vector3.ZERO
		velocity = Vector3.ZERO

	# DEBUG: Pause - Rely on pause menu for this
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Clamp input if it's over 1, otherwise leave it (for controller partial inputs)
	if desired_vel.length_squared() > 1:
		desired_vel = desired_vel.normalized()

	velocity += transform.basis * desired_vel

	if wants_jump and is_on_floor():
		velocity += -gravity_dir * jump_force

	var current_collider_height: float = $CollisionShape3D.shape.height
	var desired_collider_height := current_collider_height
	var current_collider_position_y: float = $CollisionShape3D.position.y
	var desired_collider_position_y := current_collider_position_y
	if wants_crouch:
		desired_collider_height = crouch_height
		desired_collider_position_y = crouch_height / 2 + original_height / 2.
	else:
		desired_collider_height = original_height
		desired_collider_position_y = original_height / 2.
	$CollisionShape3D.shape.height = lerpf(current_collider_height, desired_collider_height, 0.2)
	$CollisionShape3D.position.y = lerpf(current_collider_position_y, desired_collider_position_y, 0.2)
	var diff := current_collider_position_y - lerpf(current_collider_position_y, desired_collider_position_y, 0.2)
	# TODO: This runs way more than it should, but it seems fine
	if is_on_floor() and not wants_jump:
		# lock to floor
		position.y += diff

	move_and_slide()

	# Don't dampen falling
	velocity.x *= 0.8
	velocity.z *= 0.8

	# Apply gravity AFTER damping
	if !is_on_floor():
		velocity += gravity_dir * gravity * delta

	reset_desired()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos: Vector2 = -event.relative * mouse_sensitivity
		rotate_by(pos.x, pos.y)


func process_input(delta: float) -> void:
	# Input
	var move_x := Input.get_axis("move_left", "move_right")
	var move_y := Input.get_axis("move_back", "move_forward")

	# -Z forward
	desired_vel.z -= move_y * acceleration * delta
	desired_vel.x += move_x * acceleration * delta

	var look_x = Input.get_axis("look_left", "look_right") * controller_sensitivity
	var look_y = Input.get_axis("look_down", "look_up") * controller_sensitivity
	# not sure why x needs to be inverted
	rotate_by(-look_x, look_y)

	if Input.is_action_just_pressed("jump"):
		wants_jump = true

	if Input.is_action_pressed("crouch"):
		wants_crouch = true

func reset_desired() -> void:
	desired_vel = Vector3.ZERO
	wants_jump = false
	wants_crouch = false


func rotate_by(x: float, y: float) -> void:
	rotate_y(x)
	$Camera3D.rotate_x(y)

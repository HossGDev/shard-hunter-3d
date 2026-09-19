extends CharacterBody3D


# Movement
const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5


# Dash
const DASH_SPEED: float = 15.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.5


# Character rotation
const ROTATION_SPEED: float = 10.0


# CameraPivot determines movement relative to the camera.
@onready var camera_pivot: Node3D = $CameraPivot

# The visual model rotates independently from the Player body.
# This keeps the camera stable while the character turns.
@onready var model: Node3D = $Model


# Dash state and timers.
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# Update dash timers.
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta

		if dash_timer <= 0.0:
			is_dashing = false


	# Apply gravity while airborne.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Jump when the player is grounded.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# Read movement input from the configured Input Map.
	# The same actions can be used by keyboard or controller.
	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_back",
		"move_forward"
	)


	# Convert the camera's orientation into horizontal
	# forward and right directions for camera-relative movement.
	var forward: Vector3 = -camera_pivot.global_transform.basis.z
	var right: Vector3 = camera_pivot.global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()


	# Convert the 2D input into a 3D movement direction.
	var direction: Vector3 = (
		right * input_dir.x
		+ forward * input_dir.y
	).normalized()


	# Start a dash when the action is pressed.
	if (
		Input.is_action_just_pressed("dash")
		and not is_dashing
		and dash_cooldown_timer <= 0.0
	):
		# Use the current movement direction.
		# If there is no input, dash in the direction
		# the character is currently facing.
		if direction == Vector3.ZERO:
			direction = -model.global_transform.basis.z
			direction.y = 0.0
			direction = direction.normalized()

		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN


	# Apply movement based on the player's current state.
	if is_dashing:
		velocity.x = direction.x * DASH_SPEED
		velocity.z = direction.z * DASH_SPEED

	elif direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Smoothly rotate the visual model toward its
		# current movement direction.
		var target_rotation: float = atan2(
			direction.x,
			direction.z
		)

		model.rotation.y = lerp_angle(
			model.rotation.y,
			target_rotation,
			ROTATION_SPEED * delta
		)

	else:
		# Gradually reduce horizontal velocity when
		# there is no movement input.
		velocity.x = move_toward(
			velocity.x,
			0.0,
			SPEED
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			SPEED
		)


	# Move the CharacterBody3D using the calculated velocity.
	move_and_slide()

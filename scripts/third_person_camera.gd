extends Node3D


# Camera settings
@export var mouse_sensitivity: float = 0.003
@export var controller_sensitivity: float = 2.5
@export var min_pitch: float = -1.0
@export var max_pitch: float = 0.7


# Current horizontal and vertical camera rotation.
var yaw: float = 0.0
var pitch: float = 0.0


# Tracks whether the mouse is currently captured
# by the game window.
var mouse_captured: bool = true


func _ready() -> void:
	# Capture the mouse when the game starts so mouse
	# movement can control the camera.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse and trackpad movement.
	if event is InputEventMouseMotion and mouse_captured:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity

		# Limit vertical rotation to prevent the camera
		# from rotating too far in either direction.
		pitch = clamp(
			pitch,
			min_pitch,
			max_pitch
		)


	# Toggle mouse capture with the configured action.
	# This allows the cursor to be released when needed.
	if event.is_action_pressed("toggle_mouse"):
		mouse_captured = not mouse_captured

		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	# Read camera input from the right analog stick.
	# The same Input Map actions can later support
	# both keyboard/mouse and controller input.
	var look_input: Vector2 = Input.get_vector(
		"look_left",
		"look_right",
		"look_up",
		"look_down"
	)


	# Apply horizontal and vertical controller input
	# to the camera rotation.
	yaw -= look_input.x * controller_sensitivity * delta
	pitch -= look_input.y * controller_sensitivity * delta


	# Keep vertical rotation within the configured limits.
	pitch = clamp(
		pitch,
		min_pitch,
		max_pitch
	)


	# Apply the calculated rotation to the CameraPivot.
	rotation.y = yaw
	rotation.x = pitch

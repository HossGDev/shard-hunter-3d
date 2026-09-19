extends Area3D

@export var rotation_speed := 90.0
@export var float_height := 0.15
@export var float_speed := 2.0

var start_y := 0.0
var time := 0.0


func _ready() -> void:
	start_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	time += delta

	rotate_y(deg_to_rad(rotation_speed) * delta)

	position.y = start_y + sin(time * float_speed) * float_height


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		queue_free()

class_name Crystal
extends Node3D

@export var rotate_speed := 1.0
@export var rotate_amount := 1.0
@export var verticle_move_amount := 0.4
@onready var body: Node3D = $"crystal"
var push_ratio_x: float = 0.0
var push_ratio_z: float = 0.0
var pushing_face: int = -1

func set_pushing_face(face: int) -> void:
	pushing_face = face

# the crystal will lean a little when pushed/pulled
func _process(delta: float) -> void:
	var ratio_target_x := 0.0
	if pushing_face == 0:
		ratio_target_x = 1.0
	elif pushing_face == 2:
		ratio_target_x = -1.0
	if abs(ratio_target_x - push_ratio_x) > 0.000001:
		push_ratio_x = move_toward(push_ratio_x, ratio_target_x, delta * rotate_speed)
		body.rotation.x = push_ratio_x * rotate_amount
	var ratio_target_z := 0.0
	if pushing_face == 1:
		ratio_target_z = -1.0
	elif pushing_face == 3:
		ratio_target_z = 1.0
	if abs(ratio_target_z - push_ratio_z) > 0.000001:
		push_ratio_z = move_toward(push_ratio_z, ratio_target_z, delta * rotate_speed)
		body.rotation.z = push_ratio_z * rotate_amount
	var max_rot = max(abs(body.rotation.x), abs(body.rotation.z))
	# vertical and horizontal offset of the body, for emulate the different rotating pivot
	# when the body lean to different direction
	body.position.y = sin(max_rot) * verticle_move_amount
	var horizontal_move_amount_x := (1 - cos(body.rotation.z)) * verticle_move_amount
	body.position.x = horizontal_move_amount_x * (-1.0 if body.rotation.z > 0 else 1.0)
	var horizontal_move_amount_z := (1 - cos(body.rotation.x)) * verticle_move_amount
	body.position.z = horizontal_move_amount_z * (-1.0 if body.rotation.x < 0 else 1.0)

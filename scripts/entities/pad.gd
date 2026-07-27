class_name Pad
extends Node3D

@export var pressed_position: float = -0.1
@export var move_speed: float = 0.2
@onready var main_button: Node3D = $"MainButton"

var is_pressed: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos := pressed_position if is_pressed else 0.0
	main_button.position = main_button.position.move_toward(Vector3(0.0, target_pos, 0.0), move_speed * delta)
	pass

func set_pressed_im(pressed: bool):
	is_pressed = pressed
	var target_pos := pressed_position if is_pressed else 0.0
	main_button.position = Vector3(0.0, target_pos, 0.0)

func set_pressed(pressed: bool):
	is_pressed = pressed

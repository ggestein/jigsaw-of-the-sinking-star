class_name Door
extends Node3D

@export var speed := 1.0
@onready var main_body: Node3D = $"MainBody"

var unlock := false
func set_unlock_im(unlock: bool):
	self.unlock = unlock
	var target_height := 0.0 if unlock else 1.0
	main_body.position = Vector3(0.0, target_height, 0.0)

func set_unlock(unlock: bool):
	self.unlock = unlock

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_height := 0.0 if unlock else 1.0
	main_body.position = main_body.position.move_toward(Vector3(0.0, target_height, 0.0), delta * speed)

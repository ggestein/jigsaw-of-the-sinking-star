class_name Goal
extends Node3D

@export var active_mark_position: float = 0.3
@export var active_mark_rotate_speed: float = 1.0
@export var active_mark_vertical_speed: float = 0.1
@export var active_mark_float_dist: float = 0.1
@export var active_mark_float_speed: float = 1.0
@onready var active_mark: Node3D = $"ActiveMark"
var active: bool = false
var time: float = 0.0
var active_mark_center_pos: Vector3 = Vector3.ZERO

func set_active(active: bool):
	self.active = active

func _process(delta: float) -> void:
	if active:
		time += delta
		if not active_mark.visible:
			active_mark.visible = true
		active_mark.rotate(Vector3.UP, delta * active_mark_rotate_speed)
		var active_mark_height := active_mark_position
		var target_pos := Vector3(0.0, active_mark_height, 0.0)
		active_mark_center_pos = active_mark_center_pos.move_toward(target_pos, delta * active_mark_vertical_speed)
		var float_dist := active_mark_float_dist * sin(active_mark_float_speed * time)
		active_mark.position = active_mark_center_pos + Vector3(0.0, float_dist, 0.0)
	else:
		if active_mark.visible:
			active_mark.visible = false
		active_mark.position = Vector3.ZERO
		active_mark_center_pos = Vector3.ZERO
		time = 0.0

class_name ExchangeEffect
extends Node3D

var particle: GPUParticles3D
var count_down_time := 1.0

func setup(time: float, p0: Vector3, p1: Vector3):
	count_down_time = time
	position = lerp(p0, p1, 0.5)
	var ext := (p1 - p0) * 0.5
	ext = Vector3(
		max(0.2, abs(ext.x)),
		max(0.2, abs(ext.y)),
		max(0.2, abs(ext.z))
	)
	particle = get_node("GPUParticles3D") as GPUParticles3D
	particle.process_material.emission_box_extents = ext
	particle.emitting = true
	
func _process(delta: float) -> void:
	count_down_time -= delta
	if count_down_time < 0.0:
		queue_free()

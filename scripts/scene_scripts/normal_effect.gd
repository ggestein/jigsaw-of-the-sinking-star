extends Node

@export var destroy_time := 1.0
var cd_time := 0.0

func _ready() -> void:
	cd_time = destroy_time
	emit_all_particles(self)

func _process(delta: float) -> void:
	cd_time -= delta
	if cd_time < 0.0:
		queue_free()

func emit_all_particles(node: Node) -> void:
	for c in node.get_children():
		if c is GPUParticles3D:
			var actual_particle := c as GPUParticles3D
			actual_particle.emitting = true
		emit_all_particles(c)

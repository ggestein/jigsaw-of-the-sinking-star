class_name GroundGrid
extends Node3D

func setup(size: Vector2i):
	position = Vector3(size.x * 0.5, 0.02, -size.y * 0.5)
	scale = Vector3(size.x, 1.0, size.y)

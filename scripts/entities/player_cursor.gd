class_name PlayerCursor
extends Node3D

var mat: Material

func _ready() -> void:
	var mesh: MeshInstance3D = $"MeshInstance3D"
	mat = mesh.material_override

func set_character_class(cls: CoreGameplay.CharacterClass):
	var color = Vector3.ZERO
	if cls == CoreGameplay.CharacterClass.WARRIOR:
		color = Vector3(1.0, 0.0, 0.0)
	elif cls == CoreGameplay.CharacterClass.THIEF:
		color = Vector3(0.0, 1.0, 0.0)
	elif cls == CoreGameplay.CharacterClass.MAGE:
		color = Vector3(0.0, 0.0, 1.0)
	if mat:
		mat.set("shader_parameter/emission_color", color)

class_name Pad
extends Node3D

@export var pressed_position: float = -0.1
@export var move_speed: float = 0.2
@export var normal_energy: float = 0.5
@export var highlight_energy: float = 1.5
@export var energy_change_speed: float = 1.0
@onready var main_button: Node3D = $"MainButton"

var target_material: StandardMaterial3D = null

var is_pressed: bool = false

func setup_all_materials(root: Node):
	if root is MeshInstance3D:
		(root as MeshInstance3D).material_override = target_material
	for child in root.get_children():
		setup_all_materials(child)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mesh_inst := $"MainButton/MeshInstance3D" as MeshInstance3D
	target_material = mesh_inst.material_override as StandardMaterial3D
	target_material = target_material.duplicate()
	setup_all_materials(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos := pressed_position if is_pressed else 0.0
	var target_energy := highlight_energy if is_pressed else normal_energy
	main_button.position = main_button.position.move_toward(Vector3(0.0, target_pos, 0.0), move_speed * delta)
	target_material.emission_energy_multiplier = move_toward(target_material.emission_energy_multiplier, target_energy, energy_change_speed * delta)
	pass

func set_pressed_im(pressed: bool):
	is_pressed = pressed
	var target_pos := pressed_position if is_pressed else 0.0
	main_button.position = Vector3(0.0, target_pos, 0.0)
	target_material.emission_energy_multiplier = highlight_energy if is_pressed else normal_energy

func set_pressed(pressed: bool):
	is_pressed = pressed

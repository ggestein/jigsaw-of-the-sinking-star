class_name MainGame
extends Node

var current_game_instance: CoreGameplay.GameInstance
var obstacle_node_map: Dictionary[int, Node3D]
var box_node_map: Dictionary[int, Node3D]
var character_node_map: Dictionary[int, Node3D]
var main_camera: Camera3D

func setup(leve_config: CoreLevelConfig.LevelConfig, level_theme: LevelTheme.LevelThemeConfig):
	var game_instance_args := CoreLevelConfig.calculate_game_instance_args(leve_config)
	current_game_instance = CoreGameplay.create_new_game_instance(game_instance_args.level_data, game_instance_args.initial_state)
	var bg_path = level_theme.bg_packed_scene_path
	var need_generated_bg := true
	var lx := game_instance_args.level_data.range.position.x
	var ly := game_instance_args.level_data.range.position.y
	var lw := game_instance_args.level_data.range.size.x
	var lh := game_instance_args.level_data.range.size.y
	if bg_path != null and not bg_path.is_empty():
		var proto: PackedScene = load(bg_path)
		if proto != null:
			var bg_inst = proto.instantiate()
			add_child(bg_inst)
			need_generated_bg = false
	if need_generated_bg:
		for y in range(ly, ly + lh):
			for x in range(lx, lx + lw):
				var cube_inst = MeshInstance3D.new()
				cube_inst.mesh = BoxMesh.new()
				cube_inst.name = "FLOOR_%d_%d" % [x,y]
				add_child(cube_inst)
				cube_inst.position.x = x + 0.5
				cube_inst.position.y = -0.5
				cube_inst.position.z = -(y + 0.5)
				cube_inst.scale = Vector3(0.98, 1.0, 0.98)
		for obs_idx in range(0, len(current_game_instance.level_data.obstacles)):
			var obs := current_game_instance.level_data.obstacles[obs_idx]
			var cube_inst := MeshInstance3D.new()
			cube_inst.mesh = BoxMesh.new()
			cube_inst.name = "OBSTACLE_%d" % obs_idx
			add_child(cube_inst)
			cube_inst.position.x = obs.x + 0.5
			cube_inst.position.y = 0.5
			cube_inst.position.z = -(obs.y + 0.5)
			cube_inst.scale = Vector3(0.98, 1.0, 0.98)
			obstacle_node_map[obs_idx] = cube_inst
		var dir_light = DirectionalLight3D.new()
		add_child(dir_light)
		dir_light.look_at(Vector3(3.0, -1.0, 1.0))
	main_camera = Camera3D.new()
	main_camera.current = true
	add_child(main_camera)
	var focus_pos := Vector3(lx + 0.5 * lw, 0.0, -(ly + 0.5 * lh))
	var camera_pos := focus_pos + Vector3(0.0, 8.0, 4.0)
	main_camera.fov = 60.0
	main_camera.position = camera_pos
	main_camera.look_at(focus_pos)

func clearup():
	for child_idx in range(0, get_child_count()):
		get_child(child_idx).queue_free()
	current_game_instance = null
	obstacle_node_map.clear()
	box_node_map.clear()
	character_node_map.clear()
	main_camera = null

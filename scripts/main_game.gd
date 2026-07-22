class_name MainGame
extends Node

var current_game_instance: CoreGameplay.GameInstance
var obstacle_node_map: Dictionary[int, Node3D]
var box_node_map: Dictionary[int, Node3D]
var character_node_map: Dictionary[int, Node3D]

func setup(leve_config: CoreLevelConfig.LevelConfig, level_theme: LevelTheme.LevelThemeConfig):
	var game_instance_args := CoreLevelConfig.calculate_game_instance_args(leve_config)
	current_game_instance = CoreGameplay.create_new_game_instance(game_instance_args.level_data, game_instance_args.initial_state)
	# todo
	pass

func clearup():
	for child_idx in range(0, get_child_count()):
		get_child(child_idx).queue_free()

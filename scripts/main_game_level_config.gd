class_name MainGameLevelConfig
extends Node

class LevelConfigEntry:
	var name: StringName
	var level_config: CoreLevelConfig.LevelConfig
	var level_theme_config: LevelTheme.LevelThemeConfig

static func create_all_level_configs() -> Array[LevelConfigEntry]:
	var result: Array[LevelConfigEntry] = []
	var config_entry: LevelConfigEntry = null
	var level_config: CoreLevelConfig.LevelConfig = null
	var char_config: CoreLevelConfig.CharacterConfig = null
	var door_config: CoreLevelConfig.DoorConfig = null
	var level_theme_config: LevelTheme.LevelThemeConfig = null
	
	# LEVEL 1
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 1),
		Vector2i(3, 2),
		Vector2i(7, 0),
		Vector2i(7, 1),
	]
	level_config.range = Rect2i(0, 0, 11, 3)
	level_config.goals = [
		Vector2i(9, 1),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 1)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(3, 0),
		Vector2i(7, 2),
	]
	level_config.pads = []
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 1"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	# LEVEL 2
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 0),
		Vector2i(7, 0),
		Vector2i(3, 2),
		Vector2i(7, 2),
		Vector2i(0, 3),
		Vector2i(1, 3),
		Vector2i(2, 3),
		Vector2i(3, 3),
		Vector2i(4, 3),
		Vector2i(5, 3),
		Vector2i(6, 3),
		Vector2i(7, 3),
		Vector2i(8, 3),
		Vector2i(10, 3),
		Vector2i(3, 4),
		Vector2i(7, 4),
		Vector2i(3, 6),
		Vector2i(7, 6),
	]
	level_config.range = Rect2i(0, 0, 11, 7)
	level_config.goals = [
		Vector2i(1, 1)
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(0, 5)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(3, 5),
		Vector2i(4, 5),
		Vector2i(9, 5),
		Vector2i(10, 5),
		Vector2i(9, 3),
		Vector2i(2, 1),
		Vector2i(5, 1),
		Vector2i(6, 1),
		Vector2i(7, 1),
		Vector2i(8, 1),
	]
	level_config.pads = []
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 2"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	

	# LEVEL 3
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 0),
		Vector2i(3, 2),
		Vector2i(7, 1),
		Vector2i(7, 2),
	]
	level_config.range = Rect2i(0, 0, 11, 3)
	level_config.goals = [
		Vector2i(9, 1),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(0, 1)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(5, 1)
	]
	level_config.pads = [
		Vector2i(1, 1)
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(7, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 3"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	

	# LEVEL 4
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(0, 1),
		Vector2i(3, 2),
		Vector2i(5, 4),
		Vector2i(5, 5),
	]
	level_config.range = Rect2i(0, 0, 7, 6)
	level_config.goals = [
		Vector2i(6, 5),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 4)
	char_config.inst_face = 2
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(1, 3),
		Vector2i(2, 3),
		Vector2i(2, 4),
	]
	level_config.pads = [
		Vector2i(1, 1),
		Vector2i(3, 1),
		Vector2i(5, 1),
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(6, 4)
	door_config.need_pads_indices = [0, 1, 2]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 4"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	return result

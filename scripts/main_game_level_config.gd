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
		Vector2i(0, 0)
	]
	level_config.range = Rect2i(0, 0, 10, 6)
	level_config.goals = [
		Vector2i(9, 5),
		Vector2i(9, 3),
		Vector2i(9, 1),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 0)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(1, 1)
	char_config.inst_face = 2
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(1, 2)
	char_config.inst_face = 3
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(2, 0)
	]
	level_config.pads = [
		Vector2i(3, 0)
	]
	door_config = CoreLevelConfig.DoorConfig.new()
	door_config.position = Vector2i(4, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 1"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	# LEVEL 2
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(0, 0)
	]
	level_config.range = Rect2i(0, 0, 10, 6)
	level_config.goals = [
		Vector2i(9, 5),
		Vector2i(9, 3),
		Vector2i(9, 1),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 0)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(1, 1)
	char_config.inst_face = 2
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(1, 2)
	char_config.inst_face = 3
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(2, 1)
	]
	level_config.pads = [
		Vector2i(3, 0)
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(4, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 2"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	

	# LEVEL 3
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(0, 0)
	]
	level_config.range = Rect2i(0, 0, 10, 6)
	level_config.goals = [
		Vector2i(9, 5),
		Vector2i(9, 3),
		Vector2i(9, 1),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 0)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(1, 1)
	char_config.inst_face = 2
	level_config.characters.append(char_config)
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(1, 2)
	char_config.inst_face = 3
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(2, 2)
	]
	level_config.pads = [
		Vector2i(3, 0)
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(4, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 3"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	return result

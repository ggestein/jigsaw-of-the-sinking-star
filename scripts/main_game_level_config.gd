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
	
	# LEVEL 5
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
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
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
	config_entry.name = "LEVEL 5"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	# LEVEL 6
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 0),
		Vector2i(3, 1),
		Vector2i(7, 1),
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
		Vector2i(7, 5),
		Vector2i(3, 6),
		Vector2i(7, 6),
	]
	level_config.range = Rect2i(0, 0, 11, 7)
	level_config.goals = [
		Vector2i(1, 1)
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(0, 5)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(3, 5),
		Vector2i(4, 6),
		Vector2i(2, 2),
		Vector2i(3, 2),
		Vector2i(6, 4),
		Vector2i(9, 0),
		Vector2i(9, 5),
	]
	level_config.pads = [
		Vector2i(9, 1),
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(7, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 6"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	# LEVEL 7
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(6, 0),
		Vector2i(7, 0),
		Vector2i(8, 0),
		Vector2i(9, 0),
		Vector2i(10, 0),
		Vector2i(11, 0),
		Vector2i(12, 0),
		Vector2i(13, 0),
		Vector2i(14, 0),
		Vector2i(15, 0),
		Vector2i(16, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1),
		Vector2i(16, 1),
		Vector2i(0, 2),
		Vector2i(1, 2),
		Vector2i(2, 2),
		Vector2i(3, 2),
		Vector2i(4, 2),
		Vector2i(6, 2),
		Vector2i(7, 2),
		Vector2i(8, 2),
		Vector2i(11, 2),
		Vector2i(12, 2),
		Vector2i(16, 2),
		Vector2i(0, 3),
		Vector2i(1, 3),
		Vector2i(2, 3),
		Vector2i(3, 3),
		Vector2i(4, 3),
		Vector2i(8, 3),
		Vector2i(9, 3),
		Vector2i(11, 3),
		Vector2i(12, 3),
		Vector2i(13, 3),
		Vector2i(14, 3),
		Vector2i(15, 3),
		Vector2i(16, 3),
		Vector2i(0, 4),
		Vector2i(3, 4),
		Vector2i(4, 4),
		Vector2i(8, 4),
		Vector2i(12, 4),
		Vector2i(13, 4),
		Vector2i(0, 5),
		Vector2i(8, 5),
		Vector2i(0, 6),
		Vector2i(3, 6),
		Vector2i(4, 6),
		Vector2i(5, 6),
		Vector2i(6, 6),
		Vector2i(8, 6),
		Vector2i(11, 6),
		Vector2i(12, 6),
		Vector2i(13, 6),
		Vector2i(14, 6),
		Vector2i(16, 6),
		Vector2i(0, 7),
		Vector2i(3, 7),
		Vector2i(8, 7),
		Vector2i(9, 7),
		Vector2i(10, 7),
		Vector2i(11, 7),
		Vector2i(12, 7),
		Vector2i(16, 7),
		Vector2i(3, 8),
		Vector2i(8, 8),
		Vector2i(12, 8),
		Vector2i(16, 8),
		Vector2i(3, 9),
		Vector2i(16, 9),
		Vector2i(0, 10),
		Vector2i(1, 10),
		Vector2i(2, 10),
		Vector2i(3, 10),
		Vector2i(4, 10),
		Vector2i(5, 10),
		Vector2i(6, 10),
		Vector2i(7, 10),
		Vector2i(8, 10),
		Vector2i(12, 10),
		Vector2i(13, 10),
		Vector2i(14, 10),
		Vector2i(15, 10),
		Vector2i(16, 10),
	]
	level_config.range = Rect2i(0, 0, 17, 11)
	level_config.goals = [
		Vector2i(14, 8)
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(11, 5)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(9, 10),
	]
	level_config.pads = [
		Vector2i(12, 5),
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(12, 9)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(15, 6)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 7"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	

	# LEVEL 8
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 0),
		Vector2i(1, 2),
		Vector2i(5, 2),
		Vector2i(5, 4),
		Vector2i(5, 5),
	]
	level_config.range = Rect2i(0, 0, 7, 6)
	level_config.goals = [
		Vector2i(6, 5),
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
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
	config_entry.name = "LEVEL 8"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)


	# LEVEL 9
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
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
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
	config_entry.name = "LEVEL 9"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)


	# LEVEL 10
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
		Vector2i(6, 3),
		Vector2i(7, 3),
		Vector2i(8, 3),
		Vector2i(10, 3),
		Vector2i(7, 4),
		Vector2i(3, 5),
		Vector2i(7, 6),
	]
	level_config.range = Rect2i(0, 0, 11, 7)
	level_config.goals = [
		Vector2i(1, 1)
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(0, 5)
	char_config.inst_face = 1
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(1, 5),
	]
	level_config.pads = [
		Vector2i(10, 0),
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(3, 1)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 10"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)


	# LEVEL 11
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(7, 0),
		Vector2i(8, 0),
		Vector2i(9, 0),
		Vector2i(10, 0),
		Vector2i(7, 1),
		Vector2i(8, 1),
		Vector2i(9, 1),
		Vector2i(10, 1),
		Vector2i(7, 2),
		Vector2i(8, 2),
		Vector2i(9, 2),
		Vector2i(10, 2),
		Vector2i(7, 3),
		Vector2i(8, 3),
		Vector2i(9, 3),
		Vector2i(10, 3),
		Vector2i(7, 4),
		Vector2i(7, 6),
	]
	level_config.range = Rect2i(0, 0, 11, 7)
	level_config.goals = [
		Vector2i(9, 5)
	]
	level_config.characters = []
	char_config = CoreLevelConfig.CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(5, 6)
	char_config.inst_face = 2
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(3, 1),
		Vector2i(5, 1),
		Vector2i(1, 3),
		Vector2i(3, 3),
		Vector2i(5, 3),
		Vector2i(1, 5),
		Vector2i(3, 5),
		Vector2i(5, 5),
		Vector2i(10, 5),
	]
	level_config.pads = [
		Vector2i(1, 1),
	]
	door_config = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(7, 5)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	level_theme_config = LevelTheme.LevelThemeConfig.new()
	config_entry = LevelConfigEntry.new()
	config_entry.name = "LEVEL 11"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	

	# LEVEL 12
	level_config = CoreLevelConfig.LevelConfig.new()
	level_config.obstacles = [
		Vector2i(3, 0),
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
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
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
	config_entry.name = "LEVEL 12"
	config_entry.level_config = level_config
	config_entry.level_theme_config = level_theme_config
	result.append(config_entry)
	
	return result

extends Node

@onready var vbox: VBoxContainer = $"VBox"

class TestEntry:
	var name: String
	var level_config: CoreLevelConfig.LevelConfig
	var level_theme_config: LevelTheme.LevelThemeConfig

var test_entries: Array[TestEntry]
var current_main_game: MainGame = null

func setup_all_level_configs():
	var level_config := CoreLevelConfig.LevelConfig.new()
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
	var char_config := CoreLevelConfig.CharacterConfig.new()
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
	var door_config: CoreLevelConfig.DoorConfig = CoreLevelConfig.DoorConfig.new();
	door_config.position = Vector2i(4, 0)
	door_config.need_pads_indices = [0]
	level_config.doors.append(door_config)
	var level_theme_config := LevelTheme.LevelThemeConfig.new()
	var test_entry := TestEntry.new()
	test_entry.name = "LEVEL 1"
	test_entry.level_config = level_config
	test_entry.level_theme_config = level_theme_config
	test_entries.append(test_entry)
	
func level_config_button_callback(idx: int):
	printt("level_config_button_callback", idx)
	if current_main_game != null:
		current_main_game.clearup()
		current_main_game.queue_free()
	current_main_game = MainGame.new()
	current_main_game.name = "MAINGAME_%s" % test_entries[idx].name
	add_child(current_main_game)
	current_main_game.setup(test_entries[idx].level_config, test_entries[idx].level_theme_config)
	printt("SELECTED:", test_entries[idx].name)
	
func setup_buttons():
	for i in range(0, len(test_entries)):
		var btn := Button.new()
		btn.text = test_entries[i].name
		btn.connect("pressed", level_config_button_callback.bind(i))
		vbox.add_child(btn)

func _ready() -> void:
	setup_all_level_configs()
	setup_buttons()

func _input(event: InputEvent) -> void:
	if current_main_game != null:
		current_main_game.main_game_input(event)

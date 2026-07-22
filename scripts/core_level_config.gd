class_name CoreLevelConfig
extends Node

class CharacterConfig:
	var inst_cls: CoreGameplay.CharacterClass
	var inst_pos: Vector2i
	var inst_face: int

class DoorConfig:
	var position: Vector2i
	var need_pads_indices: Array[int]

class LevelConfig:
	var obstacles: Array[Vector2i]
	var range: Rect2i
	var goals: Array[Vector2i]
	var characters: Array[CharacterConfig]
	var boxes: Array[Vector2i]
	var pads: Array[Vector2i]
	var doors: Array[DoorConfig]

class GameInstanceArgs:
	var level_data: CoreGameplay.LevelData
	var initial_state: CoreGameplay.GameState

static func calculate_game_instance_args(level_config: LevelConfig) -> GameInstanceArgs:
	var level_data := CoreGameplay.LevelData.new()
	level_data.obstacles = level_config.obstacles
	level_data.range = level_config.range
	level_data.goals = level_config.goals
	level_data.character_data = []
	for cc in level_config.characters:
		level_data.character_data.append(cc.inst_cls)
	level_data.pads = level_config.pads
	level_data.doors = []
	for dc in level_config.doors:
		var door_data := CoreGameplay.DoorData.new()
		door_data.position = dc.position
		door_data.need_pads_indices = dc.need_pads_indices
		level_data.doors.append(door_data)
	var initial_state := CoreGameplay.GameState.new()
	initial_state.current_character_index = 0
	initial_state.characters = []
	for cc in level_config.characters:
		var char_inst := CoreGameplay.CharacterInstance.new()
		char_inst.inst_position = cc.inst_pos
		char_inst.inst_face = cc.inst_face
		initial_state.characters.append(char_inst)
	initial_state.boxes = []
	for b in level_config.boxes:
		var new_box_inst := CoreGameplay.BoxInstance.new()
		new_box_inst.position = b
		new_box_inst.killed = false
		initial_state.boxes.append(new_box_inst)
	var result := GameInstanceArgs.new()
	result.level_data = level_data
	result.initial_state = initial_state
	return result

extends Node2D

@onready var vbox: VBoxContainer = $"VBox"

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
	var goal: Vector2i
	var characters: Array[CharacterConfig]
	var boxes: Array[Vector2i]
	var pads: Array[Vector2i]
	var doors: Array[DoorConfig]
	
class GameInstanceArgs:
	var level_data: CoreGameplay.LevelData
	var initial_state: CoreGameplay.GameState
	
var level_configs: Array[LevelConfig]
var current_game_instance: CoreGameplay.GameInstance = null
	
static func calculate_game_instance_args(level_config: LevelConfig) -> GameInstanceArgs:
	var level_data := CoreGameplay.LevelData.new()
	level_data.obstacles = level_config.obstacles
	level_data.range = level_config.range
	level_data.goal = level_config.goal
	level_data.character_data = []
	for cc in level_config.characters:
		level_data.character_data.append(cc.inst_cls)
	level_data.pads = level_config.pads
	level_data.doors = []
	for dc in level_config.doors:
		var door_data := CoreGameplay.DoorData.new()
		door_data.position = dc.position
		door_data.need_pads_indices = dc.need_pads_indices
	var initial_state := CoreGameplay.GameState.new()
	initial_state.current_character_index = 0
	initial_state.characters = []
	for cc in level_config.characters:
		var char_inst := CoreGameplay.CharacterInstance.new()
		char_inst.inst_position = cc.inst_pos
		char_inst.inst_face = cc.inst_face
		initial_state.characters.append(char_inst)
	initial_state.boxs = []
	for b in level_config.boxes:
		initial_state.boxs.append(b)
	var result := GameInstanceArgs.new()
	result.level_data = level_data
	result.initial_state = initial_state
	return result

func setup_all_level_configs():
	var level_config := LevelConfig.new()
	level_config.obstacles = [
		Vector2i(0, 0)
	]
	level_config.range = Rect2i(0, 0, 10, 6)
	level_config.goal = Vector2i(4, 3)
	level_config.characters = []
	var char_config := CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.WARRIOR
	char_config.inst_pos = Vector2i(1, 0)
	char_config.inst_face = 0
	level_config.characters.append(char_config)
	char_config = CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.THIEF
	char_config.inst_pos = Vector2i(1, 1)
	char_config.inst_face = 0
	level_config.characters.append(char_config)
	char_config = CharacterConfig.new()
	char_config.inst_cls = CoreGameplay.CharacterClass.MAGE
	char_config.inst_pos = Vector2i(1, 2)
	char_config.inst_face = 0
	level_config.characters.append(char_config)
	level_config.boxes = [
		Vector2i(2, 0)
	]
	level_config.pads = [
		Vector2i(3, 0)
	]
	var door_config: DoorConfig = DoorConfig.new();
	door_config.position = Vector2i(4, 0)
	door_config.need_pads_indices = []
	level_config.doors.append(door_config)
	level_configs.append(level_config)
	
func level_config_button_callback(idx: int):
	printt("level_config_button_callback", idx)
	var args := calculate_game_instance_args(level_configs[idx])
	current_game_instance = CoreGameplay.create_new_game_instance(args.level_data, args.initial_state)
	printt("current_game_instance", current_game_instance)
	
func setup_buttons():
	for i in range(0, len(level_configs)):
		var btn := Button.new()
		btn.text = str(i)
		btn.connect("pressed", level_config_button_callback.bind(i))
		vbox.add_child(btn)

func _ready() -> void:
	setup_all_level_configs()
	setup_buttons()
	
func draw_range(range: Rect2i, color: Color, padding: float = 0.0):
	var rect = Rect2(
		range.position.x * 50.0 + 100.0 + padding,
		range.position.y * 50.0 + 100.0 + padding,
		range.size.x * 50 - padding * 2,
		range.size.y * 50 - padding * 2
	)
	draw_rect(rect, color)
	
func draw_arrow(pos: Vector2i, face: int):
	var center_x := pos.x * 50 + 125.0
	var center_y := pos.y * 50 + 125.0
	if face == 0:
		draw_line(Vector2(center_x, center_y - 22.0), Vector2(center_x, center_y + 22.0), Color.WHITE)
		draw_circle(Vector2(center_x, center_y + 22.0), 5, Color.WHITE)
	elif face == 1:
		draw_line(Vector2(center_x - 22.0, center_y), Vector2(center_x + 22.0, center_y), Color.WHITE)
		draw_circle(Vector2(center_x + 22.0, center_y), 5, Color.WHITE)
	elif face == 2:
		draw_line(Vector2(center_x, center_y - 22.0), Vector2(center_x, center_y + 22.0), Color.WHITE)
		draw_circle(Vector2(center_x, center_y - 22.0), 5, Color.WHITE)
	else:
		draw_line(Vector2(center_x - 22.0, center_y), Vector2(center_x + 22.0, center_y), Color.WHITE)
		draw_circle(Vector2(center_x - 22.0, center_y), 5, Color.WHITE)
	
func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	if current_game_instance == null:
		return
	var current_state = current_game_instance.history_states[len(current_game_instance.history_states) - 1]
	var level_data = current_game_instance.level_data
	draw_range(level_data.range, Color.DARK_GRAY)
	for obs in level_data.obstacles:
		draw_range(Rect2i(obs.x, obs.y, 1, 1), Color.AQUA)
	for idx in range(0, len(current_state.characters)):
		var cd: CoreGameplay.CharacterClass = level_data.character_data[idx]
		var ci: CoreGameplay.CharacterInstance = current_state.characters[idx]
		var cl: Color = Color.MAGENTA
		if cd == CoreGameplay.CharacterClass.WARRIOR:
			cl = Color.RED
		elif cd == CoreGameplay.CharacterClass.THIEF:
			cl = Color.GREEN
		elif cd == CoreGameplay.CharacterClass.MAGE:
			cl = Color.BLUE
		draw_range(Rect2i(ci.inst_position.x, ci.inst_position.y, 1, 1), cl, 5)
		draw_arrow(ci.inst_position, ci.inst_face)
	for box in current_state.boxs:
		draw_range(Rect2i(box.x, box.y, 1, 1), Color.YELLOW, 5)
	for idx in range(0, len(current_state.pads_active)):
		var pad_pos = level_data.pads[idx]
		var pad_active = current_state.pads_active[idx]
		draw_range(Rect2i(pad_pos.x, pad_pos.y, 1, 1), Color.DARK_CYAN, 5)
	for idx in range(0, len(current_state.doors_unlock)):
		var door_pos = level_data.doors[idx]
		var door_active = current_state.doors_unlock[idx]
		draw_range(Rect2i(door_pos.x, door_pos.y, 1, 1), Color.BROWN, 5)

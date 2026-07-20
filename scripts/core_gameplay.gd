class_name CoreGameplay
extends Node

enum CharacterClass { WARRIOR, THIEF, MAGE }
enum PlayerInput { MOVE_UP, MOVE_RIGHT, MOVE_DOWN, MOVE_LEFT, SWITCH, REWIND, RESET }

class CharacterInstance:
	var inst_position: Vector2i
	var inst_face: int # 0: top; 1: right; 2: down; 3: left

class DoorData:
	var position: Vector2i
	var need_pads_indices: Array[int]

class LevelData:
	var obstacles: Array[Vector2i]
	var range: Rect2i
	var goal: Vector2i
	var character_data: Array[CharacterClass]
	var pads: Array[Vector2i]
	var doors: Array[DoorData]
	
class GameState:
	var current_character_index: int
	var characters: Array[CharacterInstance] # the order matters
	var boxs: Array[Vector2i]
	var pads_active: Array[bool]
	var doors_unlock: Array[bool]

class GameInstance:
	var level_data: LevelData
	var initial_state: GameState
	var history_states: Array[GameState]
	
# Events
enum EventType {
	REWINDED, RESET, SWITCH,
	CHAR_MOVE, BOX_MOVE, CHAR_BLOCKED, PAD_ACTIVE, DOOR_UNLOCK
}
class Event:
	var type: EventType
	var params: Array[Variant]
	
static func normalize_state(level_data: LevelData, state: GameState):
	state.pads_active = calculate_pads_active(level_data, state)
	state.doors_unlock = calculate_doors_active(level_data, state)
	
static func create_new_game_instance(level_data: LevelData, initial_state: GameState) -> GameInstance:
	var result = GameInstance.new()
	result.level_data = level_data
	normalize_state(level_data, initial_state)
	result.initial_state = initial_state
	result.history_states.append(result.initial_state)
	return result

static func core_gameplay_handle_input(input: PlayerInput, game_inst: GameInstance, events: Array[Event]):
	assert(len(game_inst.history_states) > 0)
	if input == PlayerInput.REWIND:
		if len(game_inst.history_states) > 1:
			game_inst.history_states.remove_at(len(game_inst.history_states) - 1)
			var evt := Event.new()
			evt.type = EventType.REWINDED
			events.append(evt)
	elif input == PlayerInput.RESET:
		game_inst.history_states.append(game_inst.initial_state)
		var evt := Event.new()
		evt.type = EventType.REWINDED
		events.append(evt)
	elif input == PlayerInput.SWITCH:
		var cur_state := game_inst.history_states[len(game_inst.history_states) - 1]
		cur_state.current_character_index = (cur_state.current_character_index + 1) % len(cur_state.characters)
		var evt := Event.new()
		evt.type = EventType.SWITCH
		evt.params = [cur_state.current_character_index]
		events.append(evt)
	else:
		var cur_state = game_inst.history_states[len(game_inst.history_states) - 1]
		var next_state = calculate_next_state(input, game_inst.level_data, cur_state, events)
		if next_state:
			game_inst.history_states.append(next_state)
	
static func calculate_next_state(input: PlayerInput, level_data: LevelData, state: GameState, events: Array[Event]):
	var next_state := GameState.new()
	next_state.current_character_index = state.current_character_index
	next_state.characters = []
	for idx in range(0, len(state.characters)):
		var ch := state.characters[idx]
		var new_char_inst := CharacterInstance.new()
		new_char_inst.inst_id = ch.inst_id
		new_char_inst.inst_cls = ch.inst_cls
		new_char_inst.inst_position = ch.inst_position + Vector2i.UP
		next_state.characters.append(new_char_inst)
	next_state.boxs = []
	for b in state.boxs:
		next_state.boxs.append(b)
	return next_state

static func calculate_pads_active(level_data: LevelData, state: GameState) -> Array[bool]:
	var result: Array[bool] = []
	for i in range(0, len(level_data.pads)):
		result.append(false)
	return result

static func calculate_doors_active(level_data: LevelData, state: GameState) -> Array[bool]:
	var result: Array[bool] = []
	for i in range(0, len(level_data.doors)):
		result.append(false)
	return result

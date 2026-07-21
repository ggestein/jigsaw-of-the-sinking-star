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
	var boxes: Array[Vector2i]
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
	var args: Array[Variant]
	
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
		evt.args = [cur_state.current_character_index]
		events.append(evt)
	else:
		var cur_state = game_inst.history_states[len(game_inst.history_states) - 1]
		var next_state = calculate_next_state(input, game_inst.level_data, cur_state, events)
		if next_state:
			game_inst.history_states.append(next_state)

static func util_is_position_blocked(level_data: LevelData, state: GameState, position: Vector2i) -> bool:
	if not level_data.range.has_point(position):
		return true
	if level_data.obstacles.has(position):
		return true
	for door_idx in range(0, len(level_data.doors)):
		var door_data := level_data.doors[door_idx]
		if door_data.position == position and not state.doors_unlock[door_idx]:
			return true
	return false
static func util_find_movable_in_position(state: GameState, position: Vector2i) -> Array:
	for ch_idx in range(0, len(state.characters)):
		if position == state.characters[ch_idx].inst_position:
			return [1, ch_idx]
	for box_idx in range(0, len(state.boxes)):
		if position == state.boxes[box_idx]:
			return [2, box_idx]
	return [0, 0]

static func calculate_next_state(input: PlayerInput, level_data: LevelData, state: GameState, events: Array[Event]):
	var next_state := GameState.new()
	next_state.current_character_index = state.current_character_index
	next_state.characters = []
	# input to direction
	var move_vec := Vector2i.ZERO
	var next_face := -1
	if input == PlayerInput.MOVE_UP:
		move_vec = Vector2i(0, 1)
		next_face = 0
	elif input == PlayerInput.MOVE_RIGHT:
		move_vec = Vector2i(1, 0)
		next_face = 1
	elif input == PlayerInput.MOVE_DOWN:
		move_vec = Vector2i(0, -1)
		next_face = 2
	elif input == PlayerInput.MOVE_LEFT:
		move_vec = Vector2i(-1, 0)
		next_face = 3
	# character movement
	var passive_moves = []
	for idx in range(0, len(state.characters)):
		var ch := state.characters[idx]
		var new_char_inst := CharacterInstance.new()
		var chr_move_vec := move_vec if idx == state.current_character_index else Vector2i.ZERO
		var new_position := ch.inst_position + chr_move_vec
		if util_is_position_blocked(level_data, state, new_position):
			chr_move_vec = Vector2i.ZERO
		# handle abilities
		if state.current_character_index == idx:
			# warrior ability
			if level_data.character_data[idx] == CharacterClass.WARRIOR:
				if chr_move_vec != Vector2i.ZERO:
					var has_next = true
					var next_check_pos = new_position
					var next_pushable_valid = false
					var next_pushable_type = 0 # 0: unkown; 1: character; 2: box
					var next_pushable_idx = -1
					while has_next:
						has_next = false
						if util_is_position_blocked(level_data, state, next_check_pos):
							passive_moves.clear() # Collide: no passive moves
							chr_move_vec = Vector2i.ZERO # Collide: no active moves
							break
						var movable_info = util_find_movable_in_position(state, next_check_pos)
						if movable_info[0] != 0:
							next_check_pos = next_check_pos + chr_move_vec
							has_next = true
							passive_moves.append([movable_info[0], movable_info[1], next_check_pos])
			# thief ability
			if level_data.character_data[idx] == CharacterClass.THIEF:
				var thief_move_target_movable_info = util_find_movable_in_position(state, ch.inst_position + chr_move_vec)
				if thief_move_target_movable_info[0] == 0: # thief cannot push
					var back_check_pos = ch.inst_position - chr_move_vec
					var movable_info = util_find_movable_in_position(state, back_check_pos)
					if movable_info[0] != 0:
						passive_moves.append([movable_info[0], movable_info[1], ch.inst_position])
				else:
					chr_move_vec = Vector2i.ZERO
			# mage ability
			if level_data.character_data[idx] == CharacterClass.MAGE:
				var has_next = true
				var next_check_pos = new_position
				while has_next:
					has_next = false
					if util_is_position_blocked(level_data, state, next_check_pos):
						break
					var movable_info = util_find_movable_in_position(state, next_check_pos)
					if movable_info[0] != 0: # mage casts teleport and exchanges position
						chr_move_vec = Vector2i.ZERO
						passive_moves.append([1, idx, next_check_pos])
						passive_moves.append([movable_info[0], movable_info[1], ch.inst_position])
					else:
						has_next = true
						next_check_pos = next_check_pos + chr_move_vec
		
		new_char_inst.inst_position = ch.inst_position + chr_move_vec
		var chr_next_face := next_face if idx == state.current_character_index else -1
		new_char_inst.inst_face = chr_next_face if chr_next_face != -1 else ch.inst_face
		next_state.characters.append(new_char_inst)

	next_state.boxes = []
	for b in state.boxes:
		next_state.boxes.append(b)
		
	# handle passive move
	for pm in passive_moves:
		var pm_t = pm[0]
		var pm_idx = pm[1]
		var pm_pos = pm[2]
		if pm_t == 1:
			next_state.characters[pm_idx].inst_position = pm_pos
		elif pm_t == 2:
			next_state.boxes[pm_idx] = pm_pos

	next_state.pads_active = calculate_pads_active(level_data, next_state)
	next_state.doors_unlock = calculate_doors_active(level_data, next_state)
	return next_state

static func calculate_pads_active(level_data: LevelData, state: GameState) -> Array[bool]:
	var result: Array[bool] = []
	for i in range(0, len(level_data.pads)):
		var has_obj_above = false
		for chr in state.characters:
			if chr.inst_position == level_data.pads[i]:
				has_obj_above = true
				break
		if not has_obj_above:
			for box in state.boxes:
				if box == level_data.pads[i]:
					has_obj_above = true
					break
		result.append(has_obj_above)
	return result

static func calculate_doors_active(level_data: LevelData, state: GameState) -> Array[bool]:
	var result: Array[bool] = []
	for i in range(0, len(level_data.doors)):
		var door_data := level_data.doors[i]
		var has_inactive_pad := false
		for idx in door_data.need_pads_indices:
			if not state.pads_active[idx]:
				has_inactive_pad = true
				break
		result.append(not has_inactive_pad)
	return result

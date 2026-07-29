class_name CoreGameplay
extends Node

enum CharacterClass { WARRIOR, THIEF, MAGE }
enum PlayerInput { MOVE_UP, MOVE_RIGHT, MOVE_DOWN, MOVE_LEFT, SWITCH, REWIND, RESET }

class CharacterInstance:
	var inst_position: Vector2i
	var inst_face: int # 0: top; 1: right; 2: down; 3: left
	var killed: bool
	
class BoxInstance:
	var position: Vector2i
	var killed: bool

class DoorData:
	var position: Vector2i
	var need_pads_indices: Array[int]

class LevelData:
	var obstacles: Array[Vector2i]
	var range: Rect2i
	var goals: Array[Vector2i]
	var character_data: Array[CharacterClass]
	var pads: Array[Vector2i]
	var doors: Array[DoorData]
	
class GameState:
	var current_character_index: int
	var characters: Array[CharacterInstance] # the order matters
	var boxes: Array[BoxInstance]
	var pads_active: Array[bool]
	var doors_unlock: Array[bool]
	var goals_active: Array[bool]

class GameInstance:
	var level_data: LevelData
	var initial_state: GameState
	var history_states: Array[GameState]
	
# Events
enum EventType {
	REWINDED, RESET, SWITCH,
	CHAR_MOVE, CHAR_ROTATE, BOX_MOVE, CHAR_BLOCKED, PAD_ACTIVE, DOOR_UNLOCK, GOAL_ACTIVE,
	POSITION_EXCHANGE,
	KILL, WIN
}
class Event:
	var type: EventType
	var args: Array[Variant]
	
static func normalize_state(level_data: LevelData, state: GameState):
	state.pads_active = calculate_pads_active(level_data, state)
	state.doors_unlock = calculate_doors_active(level_data, state)
	state.goals_active = calculate_goals_active(level_data, state)
	
static func emit_character_rotate_event(chr_idx: int, prev_face: int, face: int, events: Array[Event]):
	print("emit_character_rotate_event")
	var evt := Event.new()
	evt.type = EventType.CHAR_ROTATE
	evt.args = [chr_idx, prev_face, face]
	events.append(evt)
	
static func create_new_game_instance(level_data: LevelData, initial_state: GameState) -> GameInstance:
	var result := GameInstance.new()
	result.level_data = level_data
	normalize_state(level_data, initial_state)
	result.initial_state = initial_state
	result.history_states.append(result.initial_state)
	return result
static func face_to_move_vec(face: int) -> Vector2i:
	var move_vec := Vector2i.ZERO
	if face == 0:
		move_vec = Vector2i(0, 1)
	elif face == 1:
		move_vec = Vector2i(1, 0)
	elif face == 2:
		move_vec = Vector2i(0, -1)
	elif face == 3:
		move_vec = Vector2i(-1, 0)
	return move_vec
static func character_block_rotate(chr_idx: int, chr_inst: CharacterInstance, face: int, events: Array[Event]):
	if chr_inst.inst_face != face:
		var prev_face := chr_inst.inst_face
		chr_inst.inst_face = face
		emit_character_rotate_event(chr_idx, prev_face, face, events)
	var evt := Event.new()
	evt.type = EventType.CHAR_BLOCKED
	var move_vec := face_to_move_vec(face)
	evt.args = [chr_idx, chr_inst.inst_position, chr_inst.inst_position + move_vec]
	events.append(evt)

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
		for i in range(0, len(game_inst.level_data.character_data)):
			cur_state.current_character_index = (cur_state.current_character_index + 1) % len(cur_state.characters)
			if not cur_state.characters[cur_state.current_character_index].killed:
				break
		var evt := Event.new()
		evt.type = EventType.SWITCH
		events.append(evt)
	else:
		var cur_state := game_inst.history_states[len(game_inst.history_states) - 1]
		var next_state_result := calculate_next_state(input, game_inst.level_data, cur_state, events)
		var next_state := next_state_result.next_state
		if next_state:
			if next_state_result.replace_top:
				game_inst.history_states[len(game_inst.history_states) - 1] = next_state
			else:
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
		var chr_inst := state.characters[ch_idx]
		if chr_inst.killed:
			continue
		if position == chr_inst.inst_position:
			return [1, ch_idx]
	for box_idx in range(0, len(state.boxes)):
		var box_inst := state.boxes[box_idx]
		if box_inst.killed:
			continue
		if position == box_inst.position:
			return [2, box_idx]
	return [0, 0]

class NextStateCalculationResult:
	var next_state: GameState
	var replace_top: bool

static func calculate_next_state(input: PlayerInput, level_data: LevelData, state: GameState, events: Array[Event]) -> NextStateCalculationResult:
	var result: NextStateCalculationResult = NextStateCalculationResult.new()
	result.replace_top = false
	result.next_state = GameState.new()
	result.next_state.current_character_index = state.current_character_index
	result.next_state.characters = []
	var has_position_change = false
	# input to direction
	var next_face := -1
	if input == PlayerInput.MOVE_UP:
		next_face = 0
	elif input == PlayerInput.MOVE_RIGHT:
		next_face = 1
	elif input == PlayerInput.MOVE_DOWN:
		next_face = 2
	elif input == PlayerInput.MOVE_LEFT:
		next_face = 3
	var move_vec := face_to_move_vec(next_face)
	# character movement
	var pos_exchange_from_type := -1
	var pos_exchange_from_idx := -1
	var pos_exchange_from_pos := Vector2i.ZERO
	var pos_exchange_to_type := -1
	var pos_exchange_to_idx := -1
	var pos_exchange_to_pos := Vector2i.ZERO
	var passive_moves = []
	for idx in range(0, len(state.characters)):
		var ch := state.characters[idx]
		var new_char_inst := CharacterInstance.new()
		new_char_inst.killed = ch.killed
		var chr_move_vec := move_vec if idx == state.current_character_index else Vector2i.ZERO
		if new_char_inst.killed:
			chr_move_vec = Vector2i.ZERO
		var new_position := ch.inst_position + chr_move_vec
		if chr_move_vec != Vector2i.ZERO and util_is_position_blocked(level_data, state, new_position):
			chr_move_vec = Vector2i.ZERO
			character_block_rotate(idx, ch, next_face, events)
		# handle abilities
		if state.current_character_index == idx:
			# warrior ability
			if level_data.character_data[idx] == CharacterClass.WARRIOR:
				if chr_move_vec != Vector2i.ZERO:
					var has_next := true
					var next_check_pos := new_position
					var next_pushable_valid := false
					var next_pushable_type := 0 # 0: unkown; 1: character; 2: box
					var next_pushable_idx := -1
					while has_next:
						has_next = false
						if util_is_position_blocked(level_data, state, next_check_pos):
							passive_moves.clear() # Collide: no passive moves
							chr_move_vec = Vector2i.ZERO # Collide: no active moves
							character_block_rotate(idx, ch, next_face, events)
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
					if chr_move_vec != Vector2i.ZERO:
						character_block_rotate(idx, ch, next_face, events)
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
						pos_exchange_from_type = 1
						pos_exchange_from_idx = idx
						pos_exchange_from_pos = next_check_pos
						pos_exchange_to_type = movable_info[0]
						pos_exchange_to_idx = movable_info[1]
						pos_exchange_to_pos = ch.inst_position
						var exchange_evt = Event.new()
						exchange_evt.type = EventType.POSITION_EXCHANGE
						exchange_evt.args = [
							pos_exchange_from_type, pos_exchange_from_idx, pos_exchange_from_pos,
							pos_exchange_to_type, pos_exchange_to_idx, pos_exchange_to_pos,
						]
						events.append(exchange_evt)
						has_position_change = true
					else:
						has_next = true
						next_check_pos = next_check_pos + chr_move_vec
		
		new_char_inst.inst_position = ch.inst_position + chr_move_vec
		var chr_next_face := next_face if idx == state.current_character_index else -1
		new_char_inst.inst_face = chr_next_face if chr_next_face != -1 else ch.inst_face
		result.next_state.characters.append(new_char_inst)

	result.next_state.boxes = []
	for b in state.boxes:
		var new_box_inst = BoxInstance.new()
		new_box_inst.position = b.position
		new_box_inst.killed = b.killed
		result.next_state.boxes.append(new_box_inst)
		
	# handle passive move
	for pm in passive_moves:
		var pm_t = pm[0]
		var pm_idx = pm[1]
		var pm_pos = pm[2]
		if pm_t == 1:
			result.next_state.characters[pm_idx].inst_position = pm_pos
		elif pm_t == 2:
			result.next_state.boxes[pm_idx].position = pm_pos

	result.next_state.pads_active = calculate_pads_active(level_data, result.next_state)
	result.next_state.doors_unlock = calculate_doors_active(level_data, result.next_state)
	result.next_state.goals_active = calculate_goals_active(level_data, result.next_state)
	# move events, check and emit
	for chr_idx in range(0, len(result.next_state.characters)):
		var prev_face := state.characters[chr_idx].inst_face
		var new_face := result.next_state.characters[chr_idx].inst_face
		if new_face != prev_face:
			emit_character_rotate_event(chr_idx, prev_face, new_face, events)
		if pos_exchange_from_type == 1 and pos_exchange_from_idx == chr_idx:
			continue
		if pos_exchange_to_type == 1 and pos_exchange_to_idx == chr_idx:
			continue
		var prev_pos := state.characters[chr_idx].inst_position
		var new_pos := result.next_state.characters[chr_idx].inst_position
		if new_pos != prev_pos:
			var evt := Event.new()
			evt.type = EventType.CHAR_MOVE
			evt.args = [chr_idx, prev_pos, new_pos]
			has_position_change = true
			events.append(evt)
	for box_idx in range(0, len(result.next_state.boxes)):
		if pos_exchange_from_type == 2 and pos_exchange_from_idx == box_idx:
			continue
		if pos_exchange_to_type == 2 and pos_exchange_to_idx == box_idx:
			continue
		var prev_pos := state.boxes[box_idx].position
		var new_pos := result.next_state.boxes[box_idx].position
		if new_pos != prev_pos:
			var evt := Event.new()
			evt.type = EventType.BOX_MOVE
			evt.args = [box_idx, prev_pos, new_pos]
			events.append(evt)
			has_position_change = true
	# pad event, check and emit
	for pad_idx in range(0, len(result.next_state.pads_active)):
		var prev_active := state.pads_active[pad_idx]
		var new_active := result.next_state.pads_active[pad_idx]
		if new_active != prev_active:
			var evt := Event.new()
			evt.type = EventType.PAD_ACTIVE
			evt.args = [pad_idx, new_active]
			events.append(evt)
	# door event, check and emit
	for door_idx in range(0, len(result.next_state.doors_unlock)):
		var prev_unlock := state.doors_unlock[door_idx]
		var new_unlock := result.next_state.doors_unlock[door_idx]
		if new_unlock != prev_unlock:
			var evt := Event.new()
			evt.type = EventType.DOOR_UNLOCK
			evt.args = [door_idx, new_unlock]
			events.append(evt)
	# goal event, check and emit
	for goal_idx in range(0, len(result.next_state.goals_active)):
		var prev_active := state.goals_active[goal_idx]
		var new_active := result.next_state.goals_active[goal_idx]
		if prev_active != new_active:
			var evt := Event.new()
			evt.type = EventType.GOAL_ACTIVE
			evt.args = [goal_idx, new_active]
			events.append(evt)
	
	# kill event, check and emit
	for door_idx in range(0, len(level_data.doors)):
		var door_pos = level_data.doors[door_idx].position
		var door_unlock = result.next_state.doors_unlock[door_idx]
		if not door_unlock:
			for chr_idx in range(0, len(result.next_state.characters)):
				var char_inst := result.next_state.characters[chr_idx]
				if (not char_inst.killed) and char_inst.inst_position == door_pos:
					var new_evt := Event.new()
					new_evt.type = EventType.KILL
					new_evt.args = [1, chr_idx]
					events.append(new_evt)
					char_inst.killed = true
			for box_idx in range(0, len(result.next_state.boxes)):
				var box_inst := result.next_state.boxes[box_idx]
				if (not box_inst.killed) and box_inst.position == door_pos:
					var new_evt := Event.new()
					new_evt.type = EventType.KILL
					new_evt.args = [2, box_idx]
					events.append(new_evt)
					box_inst.killed = true
	# win event, check and emit
	if not result.next_state.goals_active.has(false):
		var new_evt := Event.new()
		new_evt.type = EventType.WIN
		events.append(new_evt)
	result.replace_top = not has_position_change
	return result

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
				if box.position == level_data.pads[i]:
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
static func calculate_goals_active(level_data: LevelData, state: GameState) -> Array[bool]:
	var result: Array[bool] = []
	for i in range(0, len(level_data.goals)):
		var has_chr_above = false
		for chr in state.characters:
			if chr.inst_position == level_data.goals[i]:
				has_chr_above = true
				break
		result.append(has_chr_above)
	return result

class_name MainGame
extends Node

const FAST_FORWARD_DELTA_TIME_FACTOR: float = 8.0
const CAMERA_FOCUS_HEIGHT_FACTOR: float = 0.6
const CAMERA_FOCUS_BACKWARD_FACTOR: float = 0.25
const CAMERA_FOCUS_POSITION_Y_RATIO: float = 0.4

class WinProcess:
	var win_base_ticks: int
	var win_camera_base_pos: Vector3

class MoveEntry:
	var type: int # 1: character; 2: box
	var idx: int
	var from: Vector3
	var to: Vector3

class CmdNormalMove:
	var current_time: float
	var total_time: float
	var move_entries: Array[MoveEntry]
class CmdPosExchange:
	var current_time: float
	var total_time: float
	var from_type: int
	var from_idx: int
	var from_pos: Vector2i
	var to_type: int
	var to_idx: int
	var to_pos: Vector2i
class CmdCharacterBlockedMove:
	var current_time: float
	var total_time: float
	var chr_idx: int
	var from_pos: Vector3
	var to_pos: Vector3

var current_game_instance: CoreGameplay.GameInstance
var obstacle_node_map: Dictionary[int, Node3D]
var box_node_map: Dictionary[int, Crystal]
var character_node_map: Dictionary[int, Character]
var pad_node_map: Dictionary[int, Pad]
var door_node_map: Dictionary[int, Door]
var goal_node_map: Dictionary[int, Goal]
var main_camera: Camera3D
var current_player_cursor: PlayerCursor
var ground_grid: GroundGrid
var player_input_queue: Array[CoreGameplay.PlayerInput] = []
var core_gameplay_event_queue: Array[CoreGameplay.Event] = []
var processing_cmd: Variant = null
var pending_cmd: Variant = null
var waiting_move_entries: Array[MoveEntry]
var waiting_move_is_push: bool = false
var won: WinProcess = null

func setup(leve_config: CoreLevelConfig.LevelConfig, level_theme: LevelTheme.LevelThemeConfig):
	var game_instance_args := CoreLevelConfig.calculate_game_instance_args(leve_config)
	current_game_instance = CoreGameplay.create_new_game_instance(game_instance_args.level_data, game_instance_args.initial_state)
	var bg_path = level_theme.bg_packed_scene_path
	var need_generated_bg := true
	var lx := game_instance_args.level_data.range.position.x
	var ly := game_instance_args.level_data.range.position.y
	var lw := game_instance_args.level_data.range.size.x
	var lh := game_instance_args.level_data.range.size.y
	# setup bg and obstacle
	if bg_path != null and not bg_path.is_empty():
		var proto: PackedScene = load(bg_path)
		if proto != null:
			var bg_inst = proto.instantiate()
			add_child(bg_inst)
			need_generated_bg = false
	if need_generated_bg:
		for y in range(ly, ly + lh):
			for x in range(lx, lx + lw):
				var cube_inst = MeshInstance3D.new()
				cube_inst.mesh = BoxMesh.new()
				cube_inst.name = "FLOOR_%d_%d" % [x,y]
				add_child(cube_inst)
				cube_inst.position.x = x + 0.5
				cube_inst.position.y = -0.5
				cube_inst.position.z = -(y + 0.5)
				cube_inst.scale = Vector3(1.0, 1.0, 1.0)
		for obs_idx in range(0, len(current_game_instance.level_data.obstacles)):
			var obs := current_game_instance.level_data.obstacles[obs_idx]
			var cube_inst := MeshInstance3D.new()
			cube_inst.mesh = BoxMesh.new()
			cube_inst.name = "OBSTACLE_%d" % obs_idx
			add_child(cube_inst)
			cube_inst.position.x = obs.x + 0.5
			cube_inst.position.y = 0.5
			cube_inst.position.z = -(obs.y + 0.5)
			cube_inst.scale = Vector3(1.0, 1.0, 1.0)
			obstacle_node_map[obs_idx] = cube_inst
	# setup characters
	for chr_idx in range(0, len(game_instance_args.level_data.character_data)):
		var chr_cls := game_instance_args.level_data.character_data[chr_idx]
		var chr_pos := game_instance_args.initial_state.characters[chr_idx].inst_position
		var chr_face := game_instance_args.initial_state.characters[chr_idx].inst_face
		var chr_proto: PackedScene = null
		if chr_cls == CoreGameplay.CharacterClass.WARRIOR:
			chr_proto = load(AssetPathConfig.character_warrior_packedscene_path())
		elif chr_cls == CoreGameplay.CharacterClass.THIEF:
			chr_proto = load(AssetPathConfig.character_thief_packedscene_path())
		elif chr_cls == CoreGameplay.CharacterClass.MAGE:
			chr_proto = load(AssetPathConfig.character_mage_packedscene_path())
		if chr_proto != null:
			var chr_inst := chr_proto.instantiate() as Character
			add_child(chr_inst)
			chr_inst.position = grid_to_world(chr_pos)
			chr_inst.rotation = face_to_rotation(chr_face)
			character_node_map[chr_idx] = chr_inst
	# setup boxes
	for box_idx in range(0, len(game_instance_args.initial_state.boxes)):
		var box_pos := game_instance_args.initial_state.boxes[box_idx].position
		var box_proto_path := AssetPathConfig.box_red_packedscene_path()
		if level_theme.box_packed_scene_path.has(box_idx):
			var override_path := level_theme.box_packed_scene_path[box_idx]
			if override_path != null and !override_path.is_empty():
				box_proto_path = override_path
		var box_proto: PackedScene = load(box_proto_path)
		var box_inst := box_proto.instantiate() as Crystal
		add_child(box_inst)
		box_inst.position = grid_to_world(box_pos)
		box_node_map[box_idx] = box_inst
	# setup pads
	for pad_idx in range(0, len(game_instance_args.level_data.pads)):
		var pad_pos := game_instance_args.level_data.pads[pad_idx]
		var pad_proto: PackedScene = load(AssetPathConfig.pad_packedscene_path())
		var pad_inst := pad_proto.instantiate()
		pad_inst.name = "PAD_%d" % pad_idx
		add_child(pad_inst)
		pad_inst.position = grid_to_world(pad_pos)
		pad_node_map[pad_idx] = pad_inst
	# setup doors
	for door_idx in range(0, len(game_instance_args.level_data.doors)):
		var door_pos := game_instance_args.level_data.doors[door_idx].position
		var door_proto: PackedScene = load(AssetPathConfig.door_packedscene_path())
		var door_inst := door_proto.instantiate()
		door_inst.name = "DOOR_%d" % door_idx
		add_child(door_inst)
		door_inst.position = grid_to_world(door_pos)
		var actual_door_inst := door_inst as Door
		actual_door_inst.set_unlock_im(game_instance_args.initial_state.doors_unlock[door_idx])
		door_node_map[door_idx] = door_inst
	# setup goals
	for goal_idx in range(0, len(game_instance_args.level_data.goals)):
		var goal_pos := game_instance_args.level_data.goals[goal_idx]
		var goal_proto: PackedScene = load(AssetPathConfig.goal_packedscene_path())
		var goal_inst := goal_proto.instantiate()
		goal_inst.name = "GOAL_%d" % goal_idx
		add_child(goal_inst)
		goal_inst.position = grid_to_world(goal_pos)
		goal_node_map[goal_idx] = goal_inst
	# setup camera
	main_camera = Camera3D.new()
	main_camera.current = true
	add_child(main_camera)
	var focus_pos := Vector3(lx + 0.5 * lw, 0.0, -(ly + CAMERA_FOCUS_POSITION_Y_RATIO * lh))
	var diagonal_length = sqrt(lw * lw + lh * lh)
	var camera_pos := focus_pos + Vector3(
		0.0,
		CAMERA_FOCUS_HEIGHT_FACTOR * diagonal_length,
		CAMERA_FOCUS_BACKWARD_FACTOR * diagonal_length)
	main_camera.fov = 65.0
	main_camera.position = camera_pos
	main_camera.look_at(focus_pos)
	won = null
	if current_player_cursor == null:
		var player_cursor: PackedScene = load(AssetPathConfig.player_cursor_packedscene_path())
		current_player_cursor = player_cursor.instantiate()
		add_child(current_player_cursor)
	refresh_cursor_color()
	ground_grid = (load(AssetPathConfig.ground_grid_packedscene_path()) as PackedScene).instantiate()
	add_child(ground_grid)
	ground_grid.setup(current_game_instance.level_data.range.size);

static func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(grid_pos.x + 0.5, 0.0, -grid_pos.y - 0.5)
static func face_to_rotation(face: int) -> Vector3:
	var actual_face = face
	if face == 0:
		actual_face = 2
	elif face == 2:
		actual_face = 0
	return Vector3(0.0, actual_face * PI * 0.5, 0.0)
func refresh_cursor_color():
	var current_state := current_game_instance.history_states[len(current_game_instance.history_states) - 1]
	var current_idx := current_state.current_character_index
	var cls := current_game_instance.level_data.character_data[current_idx]
	current_player_cursor.set_character_class(cls)
func force_refresh():
	processing_cmd = null
	pending_cmd = null
	var current_state := current_game_instance.history_states[len(current_game_instance.history_states) - 1]
	for chr_idx in character_node_map:
		var node := character_node_map[chr_idx]
		var chr_inst := current_state.characters[chr_idx]
		node.position = grid_to_world(chr_inst.inst_position)
		node.rotation = face_to_rotation(chr_inst.inst_face)
		if chr_inst.killed:
			node.die()
		else:
			node.force_idle()
	for box_idx in box_node_map:
		var node := box_node_map[box_idx]
		var box_inst := current_state.boxes[box_idx]
		node.visible = not box_inst.killed
		node.position = grid_to_world(box_inst.position)
	for pad_idx in pad_node_map:
		var node := pad_node_map[pad_idx]
		node.set_pressed_im(current_state.pads_active[pad_idx])
	for door_idx in door_node_map:
		var node := door_node_map[door_idx]
		node.set_unlock_im(current_state.doors_unlock[door_idx])
	for goal_idx in goal_node_map:
		var node := goal_node_map[goal_idx]
		var active := current_state.goals_active[goal_idx]
		node.set_active(active)
	refresh_cursor_color()

func handle_core_gameplay_event(evt: CoreGameplay.Event):
	if evt.type == CoreGameplay.EventType.CHAR_MOVE:
		var chr_idx = evt.args[0]
		var prev_pos = evt.args[1]
		var new_pos = evt.args[2]
		# character_node_map[chr_idx].position = grid_to_world(new_pos)
		var new_move_entry = MoveEntry.new()
		new_move_entry.type = 1
		new_move_entry.idx = chr_idx
		new_move_entry.from = grid_to_world(prev_pos)
		new_move_entry.to = grid_to_world(new_pos)
		waiting_move_entries.append(new_move_entry)
	elif evt.type == CoreGameplay.EventType.CHAR_BLOCKED:
		var blocked_cmd := CmdCharacterBlockedMove.new()
		blocked_cmd.current_time = 0
		blocked_cmd.total_time = 0.2
		blocked_cmd.chr_idx = evt.args[0]
		blocked_cmd.from_pos = grid_to_world(evt.args[1])
		blocked_cmd.to_pos = grid_to_world(evt.args[2])
		append_cmd(blocked_cmd)
	elif evt.type == CoreGameplay.EventType.CHAR_ROTATE:
		var chr_idx = evt.args[0]
		var new_face = evt.args[2]
		character_node_map[chr_idx].rotation = face_to_rotation(new_face)
	elif evt.type == CoreGameplay.EventType.BOX_MOVE:
		var box_idx = evt.args[0]
		var prev_pos = evt.args[1]
		var new_pos = evt.args[2]
		# box_node_map[box_idx].position = grid_to_world(new_pos)
		var new_move_entry = MoveEntry.new()
		new_move_entry.type = 2
		new_move_entry.idx = box_idx
		new_move_entry.from = grid_to_world(prev_pos)
		new_move_entry.to = grid_to_world(new_pos)
		waiting_move_entries.append(new_move_entry)
		waiting_move_is_push = true
	elif evt.type == CoreGameplay.EventType.PAD_ACTIVE:
		var pad_idx = evt.args[0]
		var active = evt.args[1]
		pad_node_map[pad_idx].set_pressed(active)
	elif evt.type == CoreGameplay.EventType.DOOR_UNLOCK:
		var door_idx = evt.args[0]
		var unlock = evt.args[1]
		door_node_map[door_idx].set_unlock(unlock)
	elif evt.type == CoreGameplay.EventType.GOAL_ACTIVE:
		var goal_idx = evt.args[0]
		var active = evt.args[1]
		goal_node_map[goal_idx].set_active(active)
	elif evt.type == CoreGameplay.EventType.POSITION_EXCHANGE:
		var from_type = evt.args[0]
		var from_idx = evt.args[1]
		var from_pos = evt.args[2]
		var to_type = evt.args[3]
		var to_idx = evt.args[4]
		var to_pos = evt.args[5]
		var from_node = get_node3d_by_type_and_index(from_type, from_idx)
		if from_node != null:
			var to_node = get_node3d_by_type_and_index(to_type, to_idx)
			if to_node != null:
				var cmd_ex := CmdPosExchange.new()
				cmd_ex.from_type = from_type
				cmd_ex.from_idx = from_idx
				cmd_ex.from_pos = from_pos
				cmd_ex.to_type = to_type
				cmd_ex.to_idx = to_idx
				cmd_ex.to_pos = to_pos
				cmd_ex.current_time = 0.0
				cmd_ex.total_time = 0.05
				append_cmd(cmd_ex)
	elif evt.type == CoreGameplay.EventType.KILL:
		var kill_type = evt.args[0]
		var kill_idx = evt.args[1]
		var target_node: Node3D = null;
		if kill_type == 1:
			var target_chr_node := character_node_map[kill_idx]
			target_node = target_chr_node
			target_chr_node.die()
		elif kill_type == 2:
			target_node = box_node_map[kill_idx]
			target_node.visible = false
		var vfx_pos = target_node.position
		var vfx_inst: Node3D = load(AssetPathConfig.killed_effect_packedscene_path()).instantiate() 
		add_child(vfx_inst)
		vfx_inst.position = vfx_pos
	elif evt.type == CoreGameplay.EventType.SWITCH:
		refresh_cursor_color()
	elif evt.type == CoreGameplay.EventType.REWINDED:
		force_refresh()
	elif evt.type == CoreGameplay.EventType.RESET:
		force_refresh()
	elif evt.type == CoreGameplay.EventType.WIN:
		trigger_win_process()
		
func trigger_win_process():
	if won != null:
		return
	won = WinProcess.new()
	won.win_base_ticks = Time.get_ticks_usec()
	won.win_camera_base_pos = main_camera.position
	
func append_cmd(cmd):
	if pending_cmd != null:
		return
	if processing_cmd == null:
		processing_cmd = cmd
	elif pending_cmd == null:
		pending_cmd = cmd
	
func process_win():
	if won == null:
		return
	var cur_ticks := Time.get_ticks_usec()
	var delta_ticks := cur_ticks - won.win_base_ticks
	var camera_target_pos := won.win_camera_base_pos + Vector3.UP * 2 + Vector3.FORWARD * 2
	var factor: float = max(0.0, 1.0 - float(delta_ticks) / 4000000.0)
	factor = 1.0 - factor * factor
	main_camera.position = lerp(won.win_camera_base_pos, camera_target_pos, factor)
	var lx := current_game_instance.level_data.range.position.x
	var ly := current_game_instance.level_data.range.position.y
	var lw := current_game_instance.level_data.range.size.x
	var lh := current_game_instance.level_data.range.size.y
	var focus_pos := Vector3(lx + 0.5 * lw, 0.0, -(ly + CAMERA_FOCUS_POSITION_Y_RATIO * lh))
	main_camera.look_at(focus_pos)
	
func get_node3d_by_type_and_index(type: int, idx: int) -> Node3D:
	if type == 1:
		if character_node_map.has(idx):
			return character_node_map[idx]
	if type == 2:
		if box_node_map.has(idx):
			return box_node_map[idx]
	return null

func process_move_entry(entry: MoveEntry, ratio: float, need_stop: bool):
	var target_node_3d := get_node3d_by_type_and_index(entry.type, entry.idx)
	if target_node_3d != null:
		var actual_ratio = 1 - pow(1 - ratio, 3)
		target_node_3d.position = lerp(entry.from, entry.to, actual_ratio)
		if target_node_3d is Crystal:
			var crystal := target_node_3d as Crystal
			var next_face := -1
			if not need_stop:
				if entry.to.z > entry.from.z:
					next_face = 0
				elif entry.to.x > entry.from.x:
					next_face = 1
				elif entry.to.z < entry.from.z:
					next_face = 2
				elif entry.to.x < entry.from.x:
					next_face = 3
			crystal.set_pushing_face(next_face)
		elif target_node_3d is Character:
			var chr := target_node_3d as Character
			var cur_need_stop := need_stop
			# if the character is still moving in pending command, then keep play moving animation
			if cur_need_stop:
				if pending_cmd != null and pending_cmd is CmdNormalMove:
					var actual_pending_moving_cmd := pending_cmd as CmdNormalMove
					for pending_entry in actual_pending_moving_cmd.move_entries:
						if pending_entry.type == entry.type and pending_entry.idx == entry.idx:
							cur_need_stop = false
			chr.set_is_moving(not cur_need_stop)
	
func process_single_cmd(cmd: Variant, dt: float) -> float:
	cmd.current_time += dt
	if cmd is CmdNormalMove:
		var cmd_move = cmd as CmdNormalMove
		var ratio = min(1.0, cmd.current_time / cmd.total_time)
		for passive in cmd_move.move_entries:
			process_move_entry(passive, ratio, cmd.current_time >= cmd.total_time)
	elif cmd is CmdPosExchange:
		var cmd_ex = cmd as CmdPosExchange
		var from_node := get_node3d_by_type_and_index(cmd_ex.from_type, cmd_ex.from_idx)
		if from_node != null:
			var to_node := get_node3d_by_type_and_index(cmd_ex.to_type, cmd_ex.to_idx)
			if to_node != null:
				from_node.position = grid_to_world(cmd_ex.from_pos)
				to_node.position = grid_to_world(cmd_ex.to_pos)
				var vfx_proto: PackedScene = load(AssetPathConfig.exchange_effect_packedscene_path())
				var vfx_inst := vfx_proto.instantiate() as ExchangeEffect
				vfx_inst.name = "EXCHANGE_EFFECT"
				vfx_inst.setup(1.0, from_node.position + Vector3.UP * 0.5, to_node.position + Vector3.UP * 0.5)
				add_child(vfx_inst)
				vfx_proto = load(AssetPathConfig.trans_effect_packedscene_path())
				var trans_vfx_inst: Node3D = vfx_proto.instantiate()
				trans_vfx_inst.position = from_node.position
				add_child(trans_vfx_inst)
	elif cmd is CmdCharacterBlockedMove:
		var cmd_blocked = cmd as CmdCharacterBlockedMove
		var node := character_node_map[cmd_blocked.chr_idx]
		var ratio = min(1.0, cmd.current_time / cmd.total_time)
		ratio = (0.25 - pow((ratio - 0.5), 2)) * 1.1
		node.position = lerp(cmd_blocked.from_pos, cmd_blocked.to_pos, ratio)
	return cmd.current_time - cmd.total_time

func process_cmds(dt: float) -> void:
	if processing_cmd != null:
		var pdt = dt
		if pending_cmd != null:
			pdt = pdt * FAST_FORWARD_DELTA_TIME_FACTOR
		var overflow_time := process_single_cmd(processing_cmd, pdt)
		if overflow_time > 0.0:
			processing_cmd = pending_cmd
			if processing_cmd != null:
				processing_cmd.current_time = overflow_time / FAST_FORWARD_DELTA_TIME_FACTOR
			pending_cmd = null
				
func prepare_input_queue_process():
	waiting_move_entries = []
	waiting_move_is_push = false
	
func post_handle_input_queue_process():
	player_input_queue.clear()
	if len(waiting_move_entries) > 0:
		var cmd_move := CmdNormalMove.new()
		cmd_move.current_time = 0.0
		cmd_move.total_time = 0.7 if waiting_move_is_push else 0.4
		cmd_move.move_entries = waiting_move_entries
		append_cmd(cmd_move)

func process_player_cursor():
	if current_player_cursor != null:
		var current_state := current_game_instance.history_states[len(current_game_instance.history_states) - 1]
		current_player_cursor.position = character_node_map[current_state.current_character_index].position

func _process(delta: float) -> void:
	if current_game_instance == null:
		return
	prepare_input_queue_process()
	for ipt in player_input_queue:
		core_gameplay_event_queue.clear()
		CoreGameplay.core_gameplay_handle_input(ipt, current_game_instance, core_gameplay_event_queue)
		for evt in core_gameplay_event_queue:
			handle_core_gameplay_event(evt)
	post_handle_input_queue_process()
	process_cmds(delta)
	process_player_cursor()
	process_win()
	
func win_ticks() -> int:
	if won != null:
		return Time.get_ticks_usec() - won.win_base_ticks
	return -1
	
func main_game_input(evt: InputEvent):
	if current_game_instance == null or won:
		return
	if evt is InputEventKey:
		if pending_cmd != null:
			return
		var evt_key: InputEventKey = evt as InputEventKey
		if evt_key.is_pressed() and not evt_key.is_echo():
			if evt_key.keycode == KEY_W:
				player_input_queue.append(CoreGameplay.PlayerInput.MOVE_UP)
			elif evt_key.keycode == KEY_D:
				player_input_queue.append(CoreGameplay.PlayerInput.MOVE_RIGHT)
			elif evt_key.keycode == KEY_S:
				player_input_queue.append(CoreGameplay.PlayerInput.MOVE_DOWN)
			elif evt_key.keycode == KEY_A:
				player_input_queue.append(CoreGameplay.PlayerInput.MOVE_LEFT)
			elif evt_key.keycode == KEY_R:
				player_input_queue.append(CoreGameplay.PlayerInput.RESET)
			elif evt_key.keycode == KEY_Z:
				player_input_queue.append(CoreGameplay.PlayerInput.REWIND)
			elif evt_key.keycode == KEY_C:
				player_input_queue.append(CoreGameplay.PlayerInput.SWITCH)

func clearup():
	for child_idx in range(0, get_child_count()):
		get_child(child_idx).queue_free()
	current_game_instance = null
	obstacle_node_map.clear()
	box_node_map.clear()
	character_node_map.clear()
	current_player_cursor = null
	ground_grid = null
	main_camera = null
	player_input_queue = []

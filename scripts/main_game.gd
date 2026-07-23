class_name MainGame
extends Node

class WinProcess:
	var win_base_ticks: int
	var win_camera_base_pos: Vector3

var current_game_instance: CoreGameplay.GameInstance
var obstacle_node_map: Dictionary[int, Node3D]
var box_node_map: Dictionary[int, Node3D]
var character_node_map: Dictionary[int, Node3D]
var pad_node_map: Dictionary[int, Node3D]
var door_node_map: Dictionary[int, Node3D]
var goal_node_map: Dictionary[int, Node3D]
var main_camera: Camera3D
var player_input_queue: Array[CoreGameplay.PlayerInput] = []
var core_gameplay_event_queue: Array[CoreGameplay.Event] = []
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
				cube_inst.scale = Vector3(0.98, 1.0, 0.98)
		for obs_idx in range(0, len(current_game_instance.level_data.obstacles)):
			var obs := current_game_instance.level_data.obstacles[obs_idx]
			var cube_inst := MeshInstance3D.new()
			cube_inst.mesh = BoxMesh.new()
			cube_inst.name = "OBSTACLE_%d" % obs_idx
			add_child(cube_inst)
			cube_inst.position.x = obs.x + 0.5
			cube_inst.position.y = 0.5
			cube_inst.position.z = -(obs.y + 0.5)
			cube_inst.scale = Vector3(0.98, 1.0, 0.98)
			obstacle_node_map[obs_idx] = cube_inst
		var dir_light = DirectionalLight3D.new()
		add_child(dir_light)
		dir_light.look_at(Vector3(3.0, -1.0, 1.0))
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
			var chr_inst := chr_proto.instantiate() as Node3D
			add_child(chr_inst)
			chr_inst.position = grid_to_world(chr_pos)
			chr_inst.rotation = face_to_rotation(chr_face)
			character_node_map[chr_idx] = chr_inst
	# setup boxes
	for box_idx in range(0, len(game_instance_args.initial_state.boxes)):
		var box_pos := game_instance_args.initial_state.boxes[box_idx].position
		var box_proto: PackedScene = load(AssetPathConfig.box_packedscene_path())
		var box_inst := box_proto.instantiate() as Node3D
		add_child(box_inst)
		box_inst.position = grid_to_world(box_pos)
		box_node_map[box_idx] = box_inst
	# setup pads
	for pad_idx in range(0, len(game_instance_args.level_data.pads)):
		var pad_pos := game_instance_args.level_data.pads[pad_idx]
		var pad_inst := MeshInstance3D.new()
		pad_inst.mesh = BoxMesh.new()
		pad_inst.material_override = StandardMaterial3D.new()
		pad_inst.material_override.albedo_color = Color.GREEN
		pad_inst.name = "PAD_%d" % pad_pos
		add_child(pad_inst)
		pad_inst.position = grid_to_world(pad_pos) - Vector3.UP * 0.4
		pad_inst.scale = Vector3(0.98, 1.0, 0.98)
		pad_node_map[pad_idx] = pad_inst
	# setup doors
	for door_idx in range(0, len(game_instance_args.level_data.doors)):
		var door_pos := game_instance_args.level_data.doors[door_idx].position
		var door_inst := MeshInstance3D.new()
		door_inst.mesh = BoxMesh.new()
		door_inst.material_override = StandardMaterial3D.new()
		door_inst.material_override.albedo_color = Color.PURPLE
		door_inst.name = "DOOR_%d" % door_pos
		add_child(door_inst)
		door_inst.position = grid_to_world(door_pos) + Vector3.UP * 0.5
		door_inst.scale = Vector3(0.98, 1.0, 0.98)
		door_node_map[door_idx] = door_inst
	# setup goals
	for goal_idx in range(0, len(game_instance_args.level_data.goals)):
		var goal_pos := game_instance_args.level_data.goals[goal_idx]
		var goal_inst := MeshInstance3D.new()
		goal_inst.mesh = BoxMesh.new()
		goal_inst.material_override = StandardMaterial3D.new()
		goal_inst.material_override.albedo_color = Color.YELLOW
		goal_inst.name = "GOAL_%d" % goal_pos
		add_child(goal_inst)
		goal_inst.position = grid_to_world(goal_pos) - Vector3.UP * 0.4
		goal_inst.scale = Vector3(0.98, 1.0, 0.98)
		goal_node_map[goal_idx] = goal_inst
	# setup camera
	main_camera = Camera3D.new()
	main_camera.current = true
	add_child(main_camera)
	var focus_pos := Vector3(lx + 0.5 * lw, 0.0, -(ly + 0.5 * lh))
	var camera_pos := focus_pos + Vector3(0.0, 8.0, 4.0)
	main_camera.fov = 60.0
	main_camera.position = camera_pos
	main_camera.look_at(focus_pos)
	won = null

static func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(grid_pos.x + 0.5, 0.0, -grid_pos.y - 0.5)
static func face_to_rotation(face: int) -> Vector3:
	var actual_face = face
	if face == 0:
		actual_face = 2
	elif face == 2:
		actual_face = 0
	return Vector3(0.0, actual_face * PI * 0.5, 0.0)
	
func handle_core_gameplay_event(evt: CoreGameplay.Event):
	if evt.type == CoreGameplay.EventType.CHAR_MOVE:
		var chr_idx = evt.args[0]
		var prev_pos = evt.args[1]
		var new_pos = evt.args[2]
		character_node_map[chr_idx].position = grid_to_world(new_pos)
	elif evt.type == CoreGameplay.EventType.CHAR_ROTATE:
		var chr_idx = evt.args[0]
		var prev_face = evt.args[1]
		var new_face = evt.args[2]
		character_node_map[chr_idx].rotation = face_to_rotation(new_face)
	elif evt.type == CoreGameplay.EventType.BOX_MOVE:
		var box_idx = evt.args[0]
		var prev_pos = evt.args[1]
		var new_pos = evt.args[2]
		box_node_map[box_idx].position = grid_to_world(new_pos)
	elif evt.type == CoreGameplay.EventType.PAD_ACTIVE:
		var pad_idx = evt.args[0]
		var active = evt.args[1]
		pad_node_map[pad_idx].visible = not active
	elif evt.type == CoreGameplay.EventType.DOOR_UNLOCK:
		var door_idx = evt.args[0]
		var unlock = evt.args[1]
		door_node_map[door_idx].visible = not unlock
	elif evt.type == CoreGameplay.EventType.GOAL_ACTIVE:
		var goal_idx = evt.args[0]
		var active = evt.args[1]
		goal_node_map[goal_idx].material_override.albedo_color = Color.GREEN_YELLOW if active else Color.YELLOW
	elif evt.type == CoreGameplay.EventType.KILL:
		var kill_type = evt.args[0]
		var kill_idx = evt.args[1]
		if kill_type == 1:
			character_node_map[kill_idx].visible = false
		elif kill_type == 2:
			box_node_map[kill_idx].visible = false
	elif evt.type == CoreGameplay.EventType.WIN:
		trigger_win_process()
		
func trigger_win_process():
	if won != null:
		return
	won = WinProcess.new()
	won.win_base_ticks = Time.get_ticks_usec()
	won.win_camera_base_pos = main_camera.position
	
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
	var focus_pos := Vector3(lx + 0.5 * lw, 0.0, -(ly + 0.5 * lh))
	main_camera.look_at(focus_pos)

func _process(delta: float) -> void:
	if current_game_instance == null:
		return
	for ipt in player_input_queue:
		core_gameplay_event_queue.clear()
		CoreGameplay.core_gameplay_handle_input(ipt, current_game_instance, core_gameplay_event_queue)
		for evt in core_gameplay_event_queue:
			handle_core_gameplay_event(evt)
	player_input_queue.clear()
	process_win()
	
func _input(evt: InputEvent):
	if current_game_instance == null or won:
		return
	if evt is InputEventKey:
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
	main_camera = null
	player_input_queue = []

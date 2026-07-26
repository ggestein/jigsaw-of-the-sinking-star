extends Node

@export var panel_bg_color: Color
@export var panel_option_bg_color: Color
@export var panel_cursor_color: Color
@export var panel_top_padding: float = 20.0
@export var panel_left_padding: float = 20.0
@export var panel_option_stride: float = 50.0
@export var panel_option_height: float = 30.0
@export var panel_cursor_size: float = 20.0

@onready var level_panel: ColorRect = $"LevelPanel"
@onready var cover_panel: ColorRect = $"Cover"

var all_level_config_entries: Array[MainGameLevelConfig.LevelConfigEntry]
var current_select_level_config_index := 0
var panel_cursor: ColorRect = null
var panel_cursor_target_position := Vector2.ZERO
var next_select_level_config_index := -1
var to_load_level_config_index := -1
var loaded_level_config_index := -1
var current_level_base_time := -1

var current_main_game: MainGame = null

func setup_level_ui_panel():
	for idx in range(0, len(all_level_config_entries)):
		var lv := all_level_config_entries[idx]
		var option_bg := ColorRect.new()
		option_bg.name = lv.name
		level_panel.add_child(option_bg)
		option_bg.position = Vector2(panel_left_padding, panel_top_padding + idx * panel_option_stride)
		option_bg.size = Vector2(level_panel.size.x - 2 * panel_left_padding, panel_option_height)
		option_bg.color = panel_option_bg_color
		var option_label := Label.new()
		option_bg.add_child(option_label)
		option_label.text = lv.name
		option_label.size = option_bg.size
		option_label.position = Vector2.ZERO
		option_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		option_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel_cursor = ColorRect.new()
	level_panel.add_child(panel_cursor)
	panel_cursor.color = panel_cursor_color
	panel_cursor.size = Vector2(panel_cursor_size, panel_cursor_size)
	panel_cursor.position = calculate_panel_cursor_position(current_select_level_config_index)
	panel_cursor_target_position = panel_cursor.position
	
func calculate_panel_cursor_position(option_index: int) -> Vector2:
	var cursor_margin := (panel_option_height - panel_cursor_size) * 0.5
	var option_top = panel_top_padding + option_index * panel_option_stride
	var option_left = panel_left_padding
	return Vector2(cursor_margin + option_left, cursor_margin + option_top)

func _ready() -> void:
	all_level_config_entries = MainGameLevelConfig.create_all_level_configs()
	setup_level_ui_panel()
	to_load_level_config_index = current_select_level_config_index
	
func process_panel_cursor_position(dt: float):
	panel_cursor.position += (panel_cursor_target_position - panel_cursor.position) * 18 * dt
	
func process_level_transfer():
	if current_main_game == null:
		return
	var win_ticks := current_main_game.win_ticks()
	if win_ticks == -1:
		if cover_panel.visible:
			var panel_alpha_ticks := Time.get_ticks_usec() - current_level_base_time
			var alpha: float = panel_alpha_ticks / 1000000.0
			alpha = 1.0 - alpha
			cover_panel.color.a = max(0.0, alpha)
			if alpha < 0:
				cover_panel.visible = false
	else:
		var panel_alpha_ticks := win_ticks - 1200000
		if panel_alpha_ticks > 0:
			if not cover_panel.visible:
				cover_panel.visible = true
			var alpha: float = min(1.0, panel_alpha_ticks / 1000000.0)
			cover_panel.color.a = max(0.0, alpha)
			if panel_alpha_ticks > 1300000:
				to_load_level_config_index = (loaded_level_config_index + 1) % len(all_level_config_entries)
func process_level_loading():
	if to_load_level_config_index != -1 and to_load_level_config_index != loaded_level_config_index:
		if current_main_game != null:
			current_main_game.clearup()
			current_main_game.queue_free()
		current_main_game = MainGame.new()
		current_main_game.name = "MAINGAME_%s" % all_level_config_entries[to_load_level_config_index].name
		add_child(current_main_game)
		current_main_game.setup(
			all_level_config_entries[to_load_level_config_index].level_config,
			all_level_config_entries[to_load_level_config_index].level_theme_config
		)
		loaded_level_config_index = to_load_level_config_index
		to_load_level_config_index = -1
		current_level_base_time = Time.get_ticks_usec()
	
func _process(delta: float) -> void:
	if next_select_level_config_index != -1:
		current_select_level_config_index = next_select_level_config_index
		next_select_level_config_index = -1
		panel_cursor_target_position = calculate_panel_cursor_position(current_select_level_config_index)
	process_panel_cursor_position(delta)
	process_level_transfer()
	process_level_loading()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var event_key := event as InputEventKey
		if event_key.is_pressed() and not event_key.is_echo():
			if level_panel.visible:
				if event_key.keycode == KEY_W:
					if current_select_level_config_index > 0:
						next_select_level_config_index = current_select_level_config_index - 1
				if event_key.keycode == KEY_S:
					if current_select_level_config_index < len(all_level_config_entries) - 1:
						next_select_level_config_index = current_select_level_config_index + 1
				if event_key.keycode == KEY_F:
					to_load_level_config_index = current_select_level_config_index
					level_panel.visible = false
				if event_key.keycode == KEY_TAB or event_key.keycode == KEY_ESCAPE:
					level_panel.visible = false
			else:
				if event_key.keycode == KEY_TAB:
					current_select_level_config_index = loaded_level_config_index
					level_panel.visible = true
				else:
					current_main_game.main_game_input(event)

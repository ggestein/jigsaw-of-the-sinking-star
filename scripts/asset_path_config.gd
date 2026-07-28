class_name AssetPathConfig
extends Object

const CASTLE_BASE_PATH: StringName = "res://arts/kenney_castle_kit/"
const CHARACTER_BASE_PATH: StringName = "res://arts/kenney_mini_characters/"
const EFFECT_BASE_PATH: StringName = "res://scenes/effects/"
const ENTITIES_BASE_PATH: StringName = "res://scenes/entities/"
const BACKGROUND_BASE_PATH: StringName = "res://scenes/backgrounds/"

static func character_warrior_packedscene_path() -> StringName:
	return CHARACTER_BASE_PATH + "character-male-b.glb"
	
static func character_thief_packedscene_path() -> StringName:
	return CHARACTER_BASE_PATH + "character-male-a.glb"

static func character_mage_packedscene_path() -> StringName:
	return CHARACTER_BASE_PATH + "character-male-c.glb"

static func box_packedscene_path() -> StringName:
	return CASTLE_BASE_PATH + "tower-base.glb"

static func exchange_effect_packedscene_path() -> StringName:
	return EFFECT_BASE_PATH + "exchange_effect.tscn"

static func trans_effect_packedscene_path() -> StringName:
	return EFFECT_BASE_PATH + "trans_effect.tscn"

static func killed_effect_packedscene_path() -> StringName:
	return EFFECT_BASE_PATH + "killed_effect.tscn"

static func pad_packedscene_path() -> StringName:
	return ENTITIES_BASE_PATH + "pad.tscn"

static func goal_packedscene_path() -> StringName:
	return ENTITIES_BASE_PATH + "goal.tscn"

static func door_packedscene_path() -> StringName:
	return ENTITIES_BASE_PATH + "door.tscn"

static func player_cursor_packedscene_path() -> StringName:
	return ENTITIES_BASE_PATH + "player_cursor.tscn"

static func ground_grid_packedscene_path() -> StringName:
	return ENTITIES_BASE_PATH + "ground_grid.tscn"

static func background_packedscene_path(level_index: int) -> StringName:
	if level_index <= 0 or level_index > 1:
		return ""
	return BACKGROUND_BASE_PATH + ("bg_%d.tscn" % level_index)

class_name AssetPathConfig
extends Object

const CASTLE_BASE_PATH: StringName = "res://arts/kenney_castle_kit/"
const CHARACTER_BASE_PATH: StringName = "res://arts/kenney_mini_characters/"
const EFFECT_BASE_PATH: StringName = "res://scenes/effects/"

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

class_name Character
extends Node3D

const IDLE_ANIM_NAME: StringName = "idle"
const WALK_ANIM_NAME: StringName = "walk"
const DIE_ANIM_NAME: StringName = "die"

var anim_player: AnimationPlayer = null
var is_moving := false
var is_dying := false

func find_animation_player_in_children_recur(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child in root.get_children():
		var child_anim := find_animation_player_in_children_recur(child)
		if child_anim != null:
			return child_anim
	return null

func find_animation_player_in_children() -> AnimationPlayer:
	return find_animation_player_in_children_recur(self)

func _ready():
	anim_player = find_animation_player_in_children()
	print("CHARACTER[%s] : %s" % [self.name, anim_player])
	if anim_player:
		anim_player.play(IDLE_ANIM_NAME)
	
func set_is_moving(moving: bool):
	if is_moving == moving:
		return
	is_moving = moving
	if anim_player:
		if is_moving:
			anim_player.play(WALK_ANIM_NAME)
		else:
			anim_player.play(IDLE_ANIM_NAME)
		is_dying = false
	
func die():
	if anim_player and not is_dying:
		is_dying = true
		anim_player.play(DIE_ANIM_NAME)
	
func force_idle():
	if anim_player:
		is_dying = false
		anim_player.play(IDLE_ANIM_NAME)

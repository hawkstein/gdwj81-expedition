extends Node
class_name Goblin

enum GoblinType { FORAGER, SPECIALIST, SCOUT, GUZZLER }
var type:GoblinType
var level := 1
var goblin_uid := -1

func _init(p_type:GoblinType, p_goblin_uid) -> void:
	type = p_type
	goblin_uid = p_goblin_uid

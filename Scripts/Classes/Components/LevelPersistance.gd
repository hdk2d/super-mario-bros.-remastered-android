class_name LevelPersistance
extends Node

static var active_nodes := [[], []]

var active := false

@onready var path := get_path_string()

signal enabled
signal enabled_2

static func reset_states() -> void:
	active_nodes = [[], []]
	Checkpoint.old_state = [[], []]

func _ready() -> void:
	if owner == null or owner.has_meta("block_item"):
		queue_free()
		return
	path = get_path_string()
	if active_nodes[0].has(path):
		enabled.emit.call_deferred()
	if active_nodes[1].has(path):
		enabled_2.emit.call_deferred()

func set_as_active() -> void:
	if owner.has_meta("no_persist"): return
	active_nodes[0].append(path)

func set_as_active_2() -> void:
	if owner.has_meta("no_persist"): return
	active_nodes[1].append(path)

func get_path_string() -> String:
	return Global.current_level.scene_file_path + str(Vector2i(owner.global_position / 8))

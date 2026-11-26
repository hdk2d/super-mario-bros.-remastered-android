extends VBoxContainer

signal closed

var file_path := ""

var active := false

func _ready() -> void:
	set_process(false)

signal level_play
signal level_edit

func open(container: CustomLevelContainer = null) -> void:
	if container != null:
		for i in ["level_name", "level_author", "level_theme", "game_style", "level_time", "difficulty", "is_downloaded", "level_id", "thumbnail"]:
			%SelectedLevel.set(i, container.get(i))
	%SelectedLevel.update_visuals()
	LevelEditor.level_name = container.level_name
	CustomLevelMenu.current_level_file = container.file_path
	LevelEditor.level_author = container.level_author
	file_path = container.file_path
	LevelEditor.level_desc = container.level_desc
	%Description.text = container.level_desc
	show()
	await get_tree().physics_frame
	active = true
	set_process(true)
	%Play.grab_focus()

func reopen() -> void:
	show()
	await get_tree().physics_frame
	active = true
	set_process(true)
	%Play.grab_focus()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back") and active:
		closed.emit()
		close()

func load_level_file() -> bool:
	var parsed_level := JSONParser.parse_to_dict(file_path)
	if parsed_level.is_empty() or not parsed_level.has("Levels") or not (parsed_level["Levels"] is Array) or parsed_level["Levels"].size() != 5 or not parsed_level.has("Info") or not (parsed_level["Info"] is Dictionary):
		Global.log_error("Invalid custom level file: " + file_path)
		return false
	for sub_level in parsed_level["Levels"]:
		if not (sub_level is Dictionary):
			Global.log_error("Invalid sublevel data in custom level file: " + file_path)
			return false
		if sub_level.is_empty():
			continue
		if not sub_level.has("Layers") or not (sub_level["Layers"] is Array) or sub_level["Layers"].size() != 5 or not sub_level.has("Data") or not sub_level.has("BG"):
			Global.log_error("Incomplete sublevel data in custom level file: " + file_path)
			return false
	LevelEditor.level_file = parsed_level
	return true

func level_selected() -> void:
	if not load_level_file():
		return
	level_play.emit()
	active = false

func level_edited() -> void:
	if not load_level_file():
		return
	level_edit.emit()

func close() -> void:
	hide()
	set_process(false)

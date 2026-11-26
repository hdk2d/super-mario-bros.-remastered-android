extends VBoxContainer

signal level_selected(container: CustomLevelContainer)

const CUSTOM_LEVEL_CONTAINER = preload("uid://dt20tjug8m6oh")

const base64_charset := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

signal closed

var containers := []

var selected_lvl_idx := -1

func open(refresh_list := true) -> void:
	show()
	refresh()
	if selected_lvl_idx >= 0:
		%LevelContainers.get_child(selected_lvl_idx).grab_focus()
	else:
		#$TopBit/Button.grab_focus()
		#$TopBit/MarginContainer/VBoxContainer2/SelectableLabel2.grab_focus()
		$TopBit/MarginContainer/VBoxContainer2/SelectableLabel3.grab_focus()
	await get_tree().process_frame
	set_process(true)

func open_folder() -> void:
	var custom_level_path = Global.config_path.path_join("custom_levels")
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(custom_level_path))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_back"):
		closed.emit()

func close() -> void:
	hide()
	set_process(false)

func refresh() -> void:
	%LevelContainers.get_node("Label").show()
	for i in %LevelContainers.get_children():
		if i is CustomLevelContainer:
			i.queue_free()
	containers.clear()
	get_levels(Global.config_path.path_join("custom_levels"))
	get_levels(Global.config_path.path_join("custom_levels/downloaded"))

func get_levels(path : String = "") -> void:
	if path == "":
		path = Global.config_path.path_join("custom_levels")
	var idx := 0
	for i in DirAccess.get_files_at(path):
		if i.contains(".lvl") == false:
			continue
		var file_path = path + "/" + i
		var json := JSONParser.parse_to_dict(file_path)
		if json.is_empty() or not json.has("Levels") or not (json["Levels"] is Array) or json["Levels"].is_empty():
			continue
		if not json.has("Info") or not (json["Info"] is Dictionary):
			continue
		var first_level = json["Levels"][0]
		if not (first_level is Dictionary) or not first_level.has("Data"):
			continue
		var data = str(first_level["Data"]).split("=")
		if data.size() < 4:
			continue
		var theme_idx := base64_charset.find(data[0])
		var time_idx := base64_charset.find(data[1])
		var campaign_idx := base64_charset.find(data[3])
		if theme_idx < 0 or theme_idx >= Level.THEME_IDXS.size():
			continue
		if time_idx < 0 or time_idx > 1:
			continue
		if campaign_idx < 0 or campaign_idx >= Global.CAMPAIGNS.size():
			continue

		%LevelContainers.get_node("Label").hide()
		var container = CUSTOM_LEVEL_CONTAINER.instantiate()
		var info: Dictionary = json["Info"]
		container.is_downloaded = path.contains("downloaded")
		if container.is_downloaded:
			container.level_id = file_path.get_file().replace(".lvl", "")
		container.level_name = info.get("Name", "")
		container.level_author = info.get("Author", "")
		container.level_desc = info.get("Description", "")
		container.idx = idx
		container.file_path = file_path
		container.level_theme = Level.THEME_IDXS[theme_idx]
		container.level_time = time_idx
		container.game_style = Global.CAMPAIGNS[campaign_idx]
		container.selected.connect(container_selected)
		containers.append(container)
		if info.has("Difficulty"):
			container.difficulty = info["Difficulty"]
		%LevelContainers.add_child(container)
		idx += 1

func container_selected(container: CustomLevelContainer) -> void:
	level_selected.emit(container)
	selected_lvl_idx = container.get_index()

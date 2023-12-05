extends Node

const SAVE_GAME_PATH: String = "user://save.tres"

var save_dict: Dictionary = {}

func _ready() -> void:
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		
		if file.get_length() > 0:
			save_dict = file.get_var()

func save_data(data_name: String, data) -> void:
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	save_dict[data_name] = data
	
	file.store_var(save_dict)

func load_data(data_name: String) -> Dictionary:
	return {data_name: save_dict.get(data_name)} \
	if save_dict.has(data_name) \
	else {data_name: null}

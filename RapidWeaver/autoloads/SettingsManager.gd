extends Node

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	# Try to load information
	var master_volume = SaveGame.load_data("Master Volume").get("Master Volume")
	var music_volume = SaveGame.load_data("Music Volume").get("Music Volume")
	var sfx_volume = SaveGame.load_data("SFX Volume").get("SFX Volume")
	var window_mode = SaveGame.load_data("Window Mode").get("Window Mode")
	
	if master_volume != null:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
	if music_volume != null:
		AudioServer.set_bus_volume_db(music_volume, linear_to_db(music_volume))
	if sfx_volume != null:
		AudioServer.set_bus_volume_db(sfx_volume, linear_to_db(sfx_volume))
	if window_mode != null:
		if window_mode == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

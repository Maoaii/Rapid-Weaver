extends VBoxContainer

@onready var fullscreen_button: CheckButton = $FullscreenContainer/CheckButton
@onready var master_slider: HSlider = $MasterContainer/MasterSlider
@onready var master_bus = AudioServer.get_bus_index("Master")

@onready var music_slider: HSlider = $MusicContainer/MusicSlider
@onready var music_bus = AudioServer.get_bus_index("Music")

@onready var sfx_slider: HSlider = $SFXContainer/SFXSlider
@onready var sfx_bus = AudioServer.get_bus_index("SFX")


func _ready():
	fullscreen_button.grab_focus()
	
	master_slider.value = SaveGame.load_data("Master Volume").get("Master Volume")
	music_slider.value = SaveGame.load_data("Music Volume").get("Music Volume")
	sfx_slider.value = SaveGame.load_data("SFX Volume").get("SFX Volume")
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_button.button_pressed = true
	else:
		fullscreen_button.button_pressed = false


func _on_check_button_toggled(button_pressed: bool):
	# Set window mode
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Save new window mode
	SaveGame.save_data("Window Mode", button_pressed)

func _on_master_slider_value_changed(value: float):
	# Set bus volume
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	
	# Save new volume
	SaveGame.save_data("Master Volume", value)


func _on_music_slider_value_changed(value: float):
	# Set bus volume
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	
	# Save new volume
	SaveGame.save_data("Music Volume", value)


func _on_sfx_slider_value_changed(value: float):
	# Set bus volume
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	
	# Save new volume
	SaveGame.save_data("SFX Volume", value)


func _on_back_pressed():
	$"../../../..".hide()

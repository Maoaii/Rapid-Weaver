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
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_button.button_pressed = true
	else:
		fullscreen_button.button_pressed = false
	
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))


func _on_check_button_toggled(button_pressed: bool):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func _on_music_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))


func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/menus/main_menu/main_menu.tscn")

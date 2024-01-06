class_name BGMusicManager
extends Node2D

## Master bus for audio playing
@onready var master_bus = AudioServer.get_bus_index("Master")
## Music bus for audio playing
@onready var music_bus = AudioServer.get_bus_index("Music")
## SFX bus for audio playing
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

## Dictionary that holds information about all the music available.
## Doubles down as a type of music to asset converter
const type_to_music: Dictionary = {
	"menu": {
		"asset": preload("res://assets/sound/music/pixel_perfect.mp3"),
		"volume": 0
	},
	"gameplay": {
		"asset": preload("res://assets/sound/music/blockman.mp3"),
		"volume": -20
	}
}

## Audio Player for background music
var bg_music: AudioStreamPlayer2D
func set_bus_volumes(master_bus_volume: float, music_bus_volume: float, sfx_bus_volume: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, master_bus_volume)
	AudioServer.set_bus_volume_db(music_bus, music_bus_volume)
	AudioServer.set_bus_volume_db(sfx_bus, sfx_bus_volume)

func setup_audio_player() -> void:
	bg_music = AudioStreamPlayer2D.new()
	bg_music.bus = "Music"
	bg_music.process_mode = Node.PROCESS_MODE_ALWAYS
	
	await get_tree().root.ready
	
	get_tree().root.add_child(bg_music)

func _ready() -> void:
	set_bus_volumes(linear_to_db(SaveGame.load_data("Master Volume").get("Master Volume")), \
					linear_to_db(SaveGame.load_data("Music Volume").get("Music Volume")), \
					linear_to_db(SaveGame.load_data("SFX Volume").get("SFX Volume")))
	
	setup_audio_player()
	
	play_music("menu")

func play_music(type: String, at_pos: float = 0.0) -> void:
	if type_to_music.get(type) == null:
		return
	
	var music_object = type_to_music.get(type)
	var music = music_object["asset"]
	var volume = music_object["volume"]
	
	bg_music.stream = music
	bg_music.volume_db = volume
	bg_music.play(at_pos)

func muffle_music() -> void:
	bg_music.bus = "Muffle"

func unmuffle_music() -> void:
	bg_music.bus = "Music"

class_name BGMusicManager
extends Node2D

var bg_music: AudioStreamPlayer2D

var type_to_music: Dictionary = {
	"menu": {
		"asset": preload("res://assets/sound/music/pixel_perfect.mp3"),
		"volume": 0
	},
	"gameplay": {
		"asset": preload("res://assets/sound/music/blockman.mp3"),
		"volume": -20
	}
}
var last_music_pos: float = 0.0

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(SaveGame.load_data("Master Volume").get("Master Volume")))
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(SaveGame.load_data("Music Volume").get("Music Volume")))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(SaveGame.load_data("SFX Volume").get("SFX Volume")))
	
	bg_music = AudioStreamPlayer2D.new()
	bg_music.bus = "Music"
	await get_tree().root.ready
	get_tree().root.add_child(bg_music)
	
	play_music("menu")
	bg_music.process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(type: String, at_pos: float = 0.0) -> void:
	last_music_pos = bg_music.get_playback_position()
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

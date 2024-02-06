class_name SoundManager
extends Node2D

## Master bus for audio playing
@onready var master_bus = AudioServer.get_bus_index("Master")
## Music bus for audio playing
@onready var music_bus = AudioServer.get_bus_index("Music")
## SFX bus for audio playing
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

@onready var button_click_sound = preload("res://assets/sound/sfx/ui/ButtonClick.wav")
@onready var button_hover_sound = preload("res://assets/sound/sfx/ui/ButtonSelect2.wav")

## Dictionary that holds information about all the music available.
## Doubles down as a type of music to asset converter
const type_to_music: Dictionary = {
	"menu": {
		"asset": preload("res://assets/sound/music/pixel_perfect.mp3"),
		"volume": 0
	},
	"gameplay": {
		"asset": preload("res://assets/sound/music/blockman.mp3"),
		"volume": -6
	}
}

## Audio Player for background music
var bg_music: AudioStreamPlayer2D
var button_sound_player: AudioStreamPlayer2D
var last_pitch: float = 1.0


func _ready() -> void:
	
	if SaveGame.load_data("Master Volume").get("Master Volume") == null:
		set_bus_volumes(linear_to_db(0.6), linear_to_db(0.6), linear_to_db(0.6))
	else:
		set_bus_volumes(linear_to_db(SaveGame.load_data("Master Volume").get("Master Volume")), \
						linear_to_db(SaveGame.load_data("Music Volume").get("Music Volume")), \
						linear_to_db(SaveGame.load_data("SFX Volume").get("SFX Volume")))
	
	await setup_audio_players()
	
	play_music("menu")

func set_bus_volumes(master_bus_volume: float, music_bus_volume: float, sfx_bus_volume: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, master_bus_volume)
	AudioServer.set_bus_volume_db(music_bus, music_bus_volume)
	AudioServer.set_bus_volume_db(sfx_bus, sfx_bus_volume)

func setup_audio_players() -> void:
	bg_music = AudioStreamPlayer2D.new()
	bg_music.bus = "Music"
	bg_music.process_mode = Node.PROCESS_MODE_ALWAYS
	
	button_sound_player = AudioStreamPlayer2D.new()
	button_sound_player.bus = "SFX"
	button_sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	button_sound_player.stream = button_click_sound
	button_sound_player.volume_db = -15
	
	await get_tree().root.ready
	
	get_tree().root.add_child(bg_music)
	get_tree().root.add_child(button_sound_player)
	
	setup_button_sounds()

func setup_button_sounds() -> void:
	var buttons: Array[Node] = get_tree().get_nodes_in_group("Button")
	for inst in buttons:
		var btn: Button = inst
		
		#btn.focus_entered.connect(play_button_hovered_sound)
		btn.pressed.connect(play_button_clicked_sound)
		#btn.mouse_entered.connect(play_button_hovered_sound)

func play_button_clicked_sound() -> void:
	play_sfx("button_click")

func play_button_hovered_sound() -> void:
	play_sfx("button_hover")

func play_sfx(sfx_name: String) -> void:
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = pitch_scale
	if sfx_name == "button_click":
		button_sound_player.stream = button_click_sound
		button_sound_player.pitch_scale = pitch_scale
		button_sound_player.play()
	if sfx_name == "button_hover":
		button_sound_player.stream = button_hover_sound
		button_sound_player.pitch_scale = pitch_scale
		button_sound_player.play()

func play_music(type: String, fade: bool = false, at_pos: float = 0.0) -> void:
	if type_to_music.get(type) == null:
		return
	
	
	var music_object = type_to_music.get(type)
	var music = music_object["asset"]
	var volume = music_object["volume"]
	
	if fade:
		var tween = get_tree().create_tween()
		tween.tween_property(bg_music, "volume_db", -80, 0.2)
		
		bg_music.stream = music
		#bg_music.volume_db = volume
		
		tween.tween_property(bg_music, "volume_db", volume, 0.2)
		bg_music.play(at_pos)
	else:
		bg_music.stream = music
		bg_music.volume_db = volume
		bg_music.play(at_pos)

func muffle_music() -> void:
	bg_music.bus = "Muffle"

func unmuffle_music() -> void:
	bg_music.bus = "Music"

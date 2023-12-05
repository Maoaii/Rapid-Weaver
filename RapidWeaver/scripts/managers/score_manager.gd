extends Node2D


@export_group("Score Variables")
@export var fly_pickup_score: int = 5
@export var section_passed_score: int = 10


var score: int = 0
var highscore: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus._on_game_restart.connect(reset_score)
	EventBus._on_player_death.connect(reset_score)
	EventBus._on_fly_eaten.connect(fly_eaten)
	EventBus._on_section_passed.connect(section_passed)
	
	# Load highscore
	var stored_highscore = SaveGame.load_data("Highscore").get("Highscore")
	if stored_highscore != null:
		highscore = stored_highscore


func fly_eaten() -> void:
	score += fly_pickup_score
	if score > highscore:
		save_highscore()
		
	EventBus._on_score_changed.emit(score)

func section_passed() -> void:
	score += section_passed_score
	if score > highscore:
		save_highscore()
	
	EventBus._on_score_changed.emit(score)

func reset_score() -> void:
	score = 0
	EventBus._on_score_changed.emit(score)

func get_score() -> int:
	return score

func get_highscore() -> int:
	return highscore

func save_highscore() -> void:
	highscore = score
	SaveGame.save_data("Highscore", highscore)

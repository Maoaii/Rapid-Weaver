extends Node2D

@export_group("Score Variables")
@export var fly_pickup_score: int = 5
@export var section_passed_score: int = 10

var score: int = 0

func _ready() -> void:
	EventBus._on_fly_eaten.connect(fly_eaten)
	EventBus._on_section_passed.connect(section_passed)
	EventBus._on_game_restart.connect(reset_score)

func fly_eaten() -> void:
	score += fly_pickup_score
	EventBus._on_score_changed.emit(score)

func section_passed() -> void:
	score += section_passed_score
	EventBus._on_score_changed.emit(score)

func reset_score() -> void:
	score = 0
	EventBus._on_score_changed.emit(score)

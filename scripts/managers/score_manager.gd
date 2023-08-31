extends Node2D


@export_group("Score Variables")
@export var fly_pickup_score: int = 5
@export var section_passed_score: int = 10


var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus._on_fly_eaten.connect(fly_eaten)
	EventBus._on_section_passed.connect(section_passed)


func fly_eaten() -> void:
	score += fly_pickup_score
	EventBus._on_score_changed.emit(score)

func section_passed() -> void:
	score += section_passed_score
	EventBus._on_score_changed.emit(score)

func reset_score() -> void:
	score = 0
	EventBus._on_score_changed.emit(score)

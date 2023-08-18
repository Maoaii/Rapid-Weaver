extends Node


enum DIRECTIONS {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

const WINDOW_WIDTH: int = 640
const WINDOW_HEIGHT: int = 480

const SECTION_WIDTH: int = 640
const SECTION_HEIGHT: int = (640 / 16) / 2

const TILE_SIZE: int = 16

const FLY_PICKUP_SCORE: int = 1

var score: int = 0

func picked_up_fly() -> void:
	score += FLY_PICKUP_SCORE

func reset_score() -> void:
	score = 0

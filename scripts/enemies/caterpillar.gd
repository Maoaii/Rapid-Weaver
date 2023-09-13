class_name Caterpillar
extends Enemy

@export_group("Caterpillar Roam Variables")
@export var constant_roam: bool = false
@export var idle_length: float = 1
@export var move_length: float = 0.4

@onready var idle_timer: Timer = $IdleTimer
@onready var moving_timer: Timer = $MovingTimer

class_name Caterpillar
extends Enemy

@export var start_direction: Vector2 = Vector2.RIGHT

@onready var idle_timer: Timer = $IdleTimer
@onready var moving_timer: Timer = $MovingTimer

class_name Caterpillar
extends Enemy

@export_group("Caterpillar Roam Variables")
@export var constant_roam: bool = false
@export var idle_length: float = 0.6
@export var move_length: float = 0.3

@onready var idle_timer: Timer = $IdleTimer
@onready var moving_timer: Timer = $MovingTimer
@onready var hit_box: Area2D = $HitBox

func _ready() -> void:
	super._ready()
	moving_timer.start()

func disable_hitbox() -> void:
	hit_box.set_deferred("monitoring", false)

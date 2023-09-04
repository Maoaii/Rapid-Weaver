class_name Caterpillar
extends Enemy

@export var speed: float = 20.0
@export var health_component: HealthComponent

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func play_animation(animation_name: String) -> void:
	sprite.play(animation_name)

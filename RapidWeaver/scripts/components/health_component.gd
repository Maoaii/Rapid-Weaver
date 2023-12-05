class_name HealthComponent
extends Node

@export var max_health: int

var health: int

func _ready() -> void:
	health = max_health

func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	health = max_health

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	
	if health <= 0:
		pass

func heal(amount: int) -> void:
	health = min(health + amount, max_health)

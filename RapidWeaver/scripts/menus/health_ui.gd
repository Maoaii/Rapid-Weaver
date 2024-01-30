extends Control

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	EventBus._on_player_damage_taken.connect(func(): health_bar.value = max(health_bar.value - 1, 0))

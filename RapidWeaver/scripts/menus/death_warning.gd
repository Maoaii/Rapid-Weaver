class_name DeathWarning
extends CanvasLayer

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

func play_animation() -> void:
	show()
	animation.play("blink")


func stop_animation() -> void:
	hide()
	animation.stop()

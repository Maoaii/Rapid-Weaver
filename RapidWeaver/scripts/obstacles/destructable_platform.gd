class_name Destructable
extends StaticBody2D

signal _on_destroyed()

@export var destroy_time: float = 5

@onready var destroy_timer: Timer = $DestroyTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var poof_particles: CPUParticles2D = $PoofParticles
@onready var touch_detector: Area2D = $TouchDetector
var destroyed: bool = false

func _ready() -> void:
	destroy_timer.wait_time = destroy_time
	animated_sprite.play("100")

func _process(_delta: float) -> void:
	if destroyed and poof_particles.emitting == false:
		queue_free()
	
	if destroy_timer.is_stopped():
		return
	
	
	if destroy_timer.time_left <= destroy_time / 4:
		animated_sprite.play("25")
	elif destroy_timer.time_left <= destroy_time / 2:
		animated_sprite.play("50")


func start_timer() -> void:
	if destroy_timer.is_stopped():
		destroy_timer.start()


func _on_destroy_timer_timeout():
	emit_signal("_on_destroyed")
	poof_particles.restart()
	animated_sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	touch_detector.set_deferred("monitoring", false)
	destroyed = true

func _on_touch_detector_body_entered(body):
	if body.is_in_group("Player"):
		start_timer()

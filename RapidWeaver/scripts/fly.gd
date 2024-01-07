extends Area2D

@onready var poof_particles: CPUParticles2D = $PoofParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
var dead: bool = false
var last_pitch: float = 1.0

func _ready() -> void:
	$AnimationPlayer.play("Float")

func _process(_delta: float) -> void:
	if dead and poof_particles.emitting == false:
		queue_free()


func _on_body_entered(body) -> void:
	if body.is_in_group("Player") and not dead:
		EventBus._on_fly_eaten.emit()
		poof_particles.restart()
		set_deferred("monitoring", false)
		sprite.visible = false
		dead = true
		play_sfx()


func _on_area_entered(area):
	if area.name == "Hook" and not dead:
		EventBus._on_fly_eaten.emit()
		poof_particles.restart()
		set_deferred("monitoring", false)
		sprite.visible = false
		dead = true
		play_sfx()


func play_sfx() -> void:
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = pitch_scale
	$EatenSFX.pitch_scale = pitch_scale
	$EatenSFX.play()

extends Area2D

@onready var poof_particles: CPUParticles2D = $PoofParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
var dead: bool = false

func _ready() -> void:
	$AnimationPlayer.play("Float")

func _process(_delta: float) -> void:
	if dead and poof_particles.emitting == false:
		queue_free()


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		EventBus._on_fly_eaten.emit()
		poof_particles.restart()
		set_deferred("monitoring", false)
		sprite.visible = false
		dead = true


func _on_area_entered(area):
	if area.name == "Hook":
		EventBus._on_fly_eaten.emit()
		poof_particles.restart()
		set_deferred("monitoring", false)
		sprite.visible = false
		dead = true

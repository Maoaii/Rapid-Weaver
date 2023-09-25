extends Enemy

@onready var poof_particles: CPUParticles2D = $PoofParticles
@onready var hitbox: Area2D = $Hitbox

var is_dead: bool = false
var player_inside_cloud: bool = false

func _ready():
	# Select a random spriteframe and load it
	var selected_sprite = sprites.pick_random()
	
	sprite.set_sprite_frames(selected_sprite)
	
	play_animation("Idle")

func _process(_delta: float) -> void:
	if is_dead and poof_particles.emitting == false:
		queue_free()
	
	if is_dead and player_inside_cloud:
		# Send signal to hurt player
		EventBus._on_player_hurt.emit()
		
		# Send signal through event bus to slow player down
		EventBus._on_fungus_contact.emit()


func _on_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		# Do a puff vfx
		poof_particles.restart()
		
		# Disable sprite and collision shape
		sprite.hide()
		hitbox.set_deferred("monitoring", false)
		
		is_dead = true


func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		player_inside_cloud = true


func _on_hurtbox_body_exited(body):
	if body.is_in_group("Player"):
		player_inside_cloud = false

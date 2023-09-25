extends Enemy

@onready var poof_particles: CPUParticles2D = $PoofParticles

var is_dead: bool = false

func _ready():
	# Select a random spriteframe and load it
	var selected_sprite = sprites.pick_random()
	
	sprite.set_sprite_frames(selected_sprite)
	
	play_animation("Idle")

func _process(_delta: float) -> void:
	if is_dead and poof_particles.emitting == false:
		queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		# Send signal through event bus to slow player down
		
		# Do a puff vfx
		poof_particles.restart()
		
		# Disable sprite and collision shape
		sprite.hide()
		$Hitbox.set_deferred("monitoring", false)
		
		is_dead = true

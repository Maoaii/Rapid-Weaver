extends Enemy

@export var speed_slow: float
@export var zoom_slow: float
@export var web_travel_slow: float
@export var jump_height_slow: float
@export var slow_time: float

@onready var poof_particles: CPUParticles2D = $PoofParticles
@onready var hitbox: Area2D = $Hitbox

var is_popped: bool = false
var last_pitch: float = 1.0


func _ready():
	# Select a random spriteframe and load it
	var selected_sprite = sprites.pick_random()
	
	sprite.set_sprite_frames(selected_sprite)
	
	play_animation("Idle")

func _process(_delta: float) -> void:
	if is_popped and poof_particles.emitting == false:
		queue_free()
	
	if is_popped and hurt_player:
		# Send signal to hurt player
		EventBus._on_player_hurt.emit()
		
		# Send signal through event bus to slow player down
		EventBus._on_fungus_contact.emit(speed_slow, zoom_slow, web_travel_slow, jump_height_slow, slow_time)


func _on_hitbox_body_entered(body):
	if body.is_in_group("Player") and not is_popped:
		# Do a puff vfx
		poof_particles.restart()
		
		# Disable sprite and collision shape
		sprite.hide()
		hitbox.set_deferred("monitoring", false)
		
		is_popped = true
		play_sfx()


func play_sfx() -> void:
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = pitch_scale
	$ExplodeSFX.pitch_scale = pitch_scale
	$ExplodeSFX.play()


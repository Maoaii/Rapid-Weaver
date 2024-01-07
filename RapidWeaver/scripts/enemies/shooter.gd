class_name Shooter
extends Enemy

@export_group("Projectile Variables")
@export var shoot_time: float = 2.0
@export var shell: PackedScene

@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var shoot_timer: Timer = $ShootTimer
@onready var hit_box: Area2D = $Hitbox

var shoot_last_pitch: float = 1.0

func _ready() -> void:
	death_audio_player = AudioStreamPlayer2D.new()
	death_audio_player.volume_db = -15
	death_audio_player.bus = "SFX"
	death_audio_player.stream = death_sfx
	await self.ready
	add_child(death_audio_player)
	
	shoot_timer.wait_time = shoot_time

func shoot(enemy_pos: Vector2) -> void:
	# Target enemy's center position
	enemy_pos += Vector2(8, -2.5)
	
	# Spawn a shell
	var shell_instance = shell.instantiate()
	shell_instance.global_position = global_position
	get_tree().root.add_child(shell_instance)
	
	# Give it velocity to hit the player
	shell_instance.set_dir(global_position.direction_to(enemy_pos).normalized())
	play_shoot_sound()

func disable_hitbox() -> void:
	hit_box.set_deferred("monitoring", false)

func play_shoot_sound() -> void:
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - shoot_last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	shoot_last_pitch = pitch_scale
	$ShootSFX.pitch_scale = pitch_scale
	$ShootSFX.play()

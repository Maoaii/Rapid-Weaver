class_name Enemy
extends CharacterBody2D

@export_group("Sprite Variables")
@export var sprites: Array[SpriteFrames]

@export_group("Movement variables")
@export var x_start_direction: Vector2 = Vector2.RIGHT
@export var y_start_direction: Vector2 = Vector2.ZERO
@export var horizontal_speed: float = 50.0
@export var vertical_speed: float = 20.0

@export_group("Death Variables")
@export var death_animation_time: float = 2

@export_group("Sounds")
@export var death_sfx: AudioStream

@export_group("Components")
@export var health_component: HealthComponent
@export var left_ledge_detector: RayCast2D
@export var right_ledge_detector: RayCast2D
@export var death_vfx: CPUParticles2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_box: Area2D = $Hurtbox

var x_dir: Vector2
var y_dir: Vector2
var hurt_player: bool = false
var is_dead: bool = false
var last_pitch: float = 1.0
var death_audio_player: AudioStreamPlayer2D

func _ready() -> void:
	# Select a random spriteframe and load it
	var selected_sprite = sprites.pick_random()
	
	sprite.set_sprite_frames(selected_sprite)
	
	x_dir = [Vector2(-1, 0), Vector2(1, 0)].pick_random()
	y_dir = y_start_direction
	
	death_audio_player = AudioStreamPlayer2D.new()
	death_audio_player.volume_db = -15
	death_audio_player.bus = "SFX"
	death_audio_player.stream = death_sfx
	
	await self.ready
	add_child(death_audio_player)

func _process(_delta: float) -> void:
	if hurt_player:
		EventBus._on_knockback_player.emit(global_position)
		EventBus._on_player_hurt.emit()
	
	if death_vfx:
		if is_dead and death_vfx.emitting == false:
			queue_free()
	elif is_dead:
		queue_free()

func flip_enemy() -> void:
	if x_dir == Vector2.RIGHT:
		position.x -= 5
	else:
		position.x += 5
	
	x_dir = Vector2.RIGHT if x_dir == Vector2.LEFT else Vector2.LEFT
	
	flip_sprite()

func flip_sprite() -> void:
	if x_dir == Vector2.RIGHT:
		sprite.flip_h = false
	elif x_dir == Vector2.LEFT:
		sprite.flip_h = true


func play_animation(animation_name: String) -> void:
	if sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)


func move_x() -> void:
	velocity.x = horizontal_speed * x_dir.x


func move_y() -> void:
	velocity.y = vertical_speed * y_dir.y


func is_on_ledge() -> bool:
	return not left_ledge_detector.is_colliding() or \
		   not right_ledge_detector.is_colliding()

func fall_down() -> void:
	velocity.y += 10

func dead() -> void:
	velocity.x = 0
	x_dir = Vector2.ZERO
	y_dir = Vector2.ZERO
	
	hurt_box.set_deferred("monitoring", false)
	
	set_collision_layer_value(4, false)
	
	play_sfx()

func play_sfx() -> void:
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = pitch_scale
	death_audio_player.pitch_scale = pitch_scale
	death_audio_player.play()

func die() -> void:
	if death_vfx:
		death_vfx.restart()
		sprite.visible = false
		hurt_box.set_deferred("monitoring", false)
	
	is_dead = true

func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		hurt_player = true

func _on_hurtbox_body_exited(body):
	if body.is_in_group("Player"):
		hurt_player = false

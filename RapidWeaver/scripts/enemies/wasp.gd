class_name Wasp
extends Enemy

@export_group("Sine Wave Movement Variables")
@export_range(1, 1000) var frequency: float = 5
@export_range(1, 1000) var amplitude: float = 150

@export_group("Chase Movement Variables")
@export var speed: float = 50

@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector
@onready var hit_box: Area2D = $HitBox

var time: float = 0

func move_sinusoid(delta: float, dir: Vector2) -> void:
	if abs(dir.x) > 0:
		velocity.x = 0
	else:
		velocity.y = 0
	
	time += delta
	
	var movement = cos(time * frequency) * amplitude * dir
	
	velocity += movement

func hit_wall() -> bool:
	return left_wall_detector.is_colliding() or right_wall_detector.is_colliding() or global_position.x <= 160 or global_position.x >= 480

func follow(player: Player):
	var dir = global_position.direction_to(player.global_position).normalized()
	velocity.x = dir.x * speed
	velocity.y = dir.y * speed

func disable_hitbox() -> void:
	hit_box.set_deferred("monitoring", false)

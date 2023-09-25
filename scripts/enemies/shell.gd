extends CharacterBody2D

@export var dir: Vector2 = Vector2.ZERO
@export var speed: float = 1200.0
@export var gravity: float = 1000.0
@export_range(0, 1, 0.05) var bounce_damping: float = 0.6

func set_dir(new_dir: Vector2) -> void:
	dir = new_dir
	
	velocity = dir * speed

func _physics_process(delta: float) -> void:
	#velocity.y += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if not collision:
		return
	
	queue_free()

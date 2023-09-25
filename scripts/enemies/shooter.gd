class_name Shooter
extends Enemy

@export_group("Projectile Variables")
@export var shoot_time: float = 2.0
@export var shell: PackedScene

@onready var trajectory_line: Line2D = $TrajectoryLine

func shoot(enemy_pos: Vector2) -> void:
	# Spawn a shell
	var shell_instance = shell.instantiate()
	shell_instance.global_position = global_position
	get_tree().root.add_child(shell_instance)
	
	# Give it velocity to hit the player
	shell_instance.set_dir(global_position.direction_to(enemy_pos).normalized())

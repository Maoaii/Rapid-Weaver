extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Moving")


func _physics_update(delta: float) -> void:
	enemy.move_x()
	enemy.move_sinusoid(delta, Vector2.UP)
	enemy.move_and_slide()
	
	if enemy.hit_wall():
		enemy.flip_enemy()

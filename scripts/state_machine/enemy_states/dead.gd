extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Dead")
	
	enemy.dead()
	
	get_tree().create_timer(enemy.death_animation_time).timeout.connect(enemy.queue_free)

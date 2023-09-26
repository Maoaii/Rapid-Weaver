extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Dead")
	
	EventBus._on_player_bounce.emit()
	enemy.disable_hitbox()
	enemy.dead()
	
	get_tree().create_timer(enemy.death_animation_time).timeout.connect(enemy.queue_free)

func _physics_update(_delta: float) -> void:
	enemy.fall_down()
	enemy.move_and_slide()

extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.dead()
	enemy.disable_hitbox()
	enemy.play_animation("Dead")
	
	EventBus._on_player_bounce.emit()
	EventBus._on_enemy_killed.emit()
	
	get_tree().create_timer(enemy.death_animation_time).timeout.connect(enemy.die)

func _physics_update(_delta: float) -> void:
	enemy.fall_down()
	enemy.move_and_slide()

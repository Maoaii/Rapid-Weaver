extends EnemyState

var last_dir: Vector2

func _enter(_msg := {}) -> void:
	enemy.play_animation("Walking")
	if not last_dir:
		last_dir = enemy.x_start_direction
	
	enemy.x_dir = last_dir
	
	
	enemy.moving_timer.start(enemy.move_length)
	if not enemy.moving_timer.timeout.is_connected(moving_timer_ended):
		enemy.moving_timer.timeout.connect(moving_timer_ended)

func _exit() -> void:
	last_dir = enemy.x_dir
	enemy.moving_timer.stop()

func _physics_update(_delta: float) -> void:
	enemy.move_x()
	enemy.move_and_slide()
	
	if enemy.is_on_wall():
		enemy.flip_enemy()
	
	if enemy.left_ledge_detector and enemy.right_ledge_detector:
		if enemy.is_on_ledge():
			enemy.flip_enemy()


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		#state_machine.transition_to("Dead")
		return 


func moving_timer_ended() -> void:
	state_machine.transition_to("Idle")
	return

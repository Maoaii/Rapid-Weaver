extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Walking")


func _physics_process(_delta: float) -> void:
	enemy.move_x()
	enemy.move_and_slide()
	
	if enemy.is_on_wall():
		enemy.flip_enemy()
	
	if enemy.left_ledge_detector and enemy.right_ledge_detector:
		if enemy.is_on_ledge():
			enemy.flip_enemy()


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		state_machine.transition_to("Dead")

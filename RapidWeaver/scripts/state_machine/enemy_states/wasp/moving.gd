extends EnemyState

var player: Player

func _enter(_msg := {}) -> void:
	enemy.play_animation("Walking")


func _physics_update(delta: float) -> void:
	if is_instance_valid(player):
		enemy.follow(player)
	else:
		enemy.move_x()
		enemy.move_sinusoid(delta, Vector2.UP)
	
	enemy.move_and_slide()
	
	if enemy.hit_wall():
		enemy.flip_enemy()

func _on_aggro_range_body_entered(body):
	if body.is_in_group("Player"):
		player = body


func _on_aggro_range_body_exited(body):
	if body.is_in_group("Player"):
		player = null


func _on_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		
		state_machine.transition_to("Dead")

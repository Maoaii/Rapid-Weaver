extends EnemyState

var player: Player
var bouncing: bool = false
var reposition_direction: Vector2

func _enter(_msg := {}) -> void:
	enemy.play_animation("Moving")


func _physics_update(delta: float) -> void:
	if not enemy.reposition_timer.is_stopped():
		enemy.reposition(reposition_direction)
	elif is_instance_valid(player):
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


func _on_hurtbox_body_entered(body):
	if body.is_in_group("Player"):
		reposition_direction = -enemy.global_position.direction_to(player.global_position).normalized()
		enemy.reposition_timer.start()

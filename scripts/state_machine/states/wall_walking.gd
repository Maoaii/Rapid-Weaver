extends PlayerState


func _enter(_msg := {}):
	player.is_sticky = true
	
	if player.is_colliding_left:
		player.current_up = Vector2.RIGHT
	else:
		player.current_up = Vector2.LEFT


func _physics_update(delta: float) -> void:
	move(player.y_direction, delta)
	
	cap_velocity()
	
	# Transition to idle
	if player.velocity.y == 0:
		state_machine.transition_to("Idle")
	
	# Transition to ground walk
	if player.is_colliding_down and player.x_direction:
		state_machine.transition_to("Walking")
	
	# Transition to ceiling walk
	if player.is_colliding_up and player.x_direction:
		state_machine.transition_to("CeilingWalk")
	
	# Transition to air (with jump)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to air (without jump)
	if not player.is_colliding_left and not player.is_colliding_right:
		state_machine.transition_to("Air")


func move(direction, delta):
	# Accelerate
	if direction:
		player.velocity.y += direction * player.move_acceleration * player.max_speed * delta
	# Decelerate
	elif player.velocity.y < 0:
		player.velocity.y += player.move_deceleration * player.max_speed * delta
		player.velocity.y = min(player.velocity.x, 0)
	elif player.velocity.y > 0:
		player.velocity.y -= player.move_deceleration * player.max_speed * delta
		player.velocity.y = max(player.velocity.x, 0)
	
	player.move_and_slide()

func cap_velocity():
	player.velocity.y = clampf(player.velocity.y, -player.max_speed, player.max_speed)

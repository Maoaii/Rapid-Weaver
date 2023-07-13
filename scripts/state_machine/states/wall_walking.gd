extends PlayerState


func _enter(_msg := {}):
	player.is_sticky = true


func _physics_update(delta: float) -> void:
	move(player.get_y_input(), delta)
	
	flip_sprite()
	
	cap_velocity()
	
	# Transition to idle
	if player.is_y_stationary():
		state_machine.transition_to("Idle")
	
	# Transition to air (with jump)
	if Input.is_action_just_pressed("jump"):
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to air (without jump)
	if not player.is_on_wall():
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Air")
	
	if player.is_on_wall() and player.is_colliding_left() and player.is_stuck_left() and player.has_input_right():
		player.set_current_down(Vector2.UP)
		player.velocity.x = 0
		state_machine.transition_to("CeilingWalk")
	
	if player.is_on_wall() and player.is_colliding_right() and player.is_stuck_right() and player.has_input_left():
		player.set_current_down(Vector2.UP)
		player.velocity.x = 0
		state_machine.transition_to("CeilingWalk")
	
	if player.is_on_wall() and player.is_colliding_left() and player.is_stuck_right() and player.has_input_left():
		player.set_current_down(Vector2.DOWN)
		player.velocity.x = 0
		state_machine.transition_to("Walking")
		
	if player.is_on_wall() and player.is_colliding_right() and player.is_stuck_left() and player.has_input_right():
		player.set_current_down(Vector2.DOWN)
		player.velocity.x = 0
		state_machine.transition_to("Walking")


func move(direction, delta):
	# Accelerate
	if direction:
		player.velocity.y += direction * player.move_acceleration * player.max_speed * delta
	# Decelerate
	elif player.velocity.y < 0:
		player.velocity.y += player.move_deceleration * player.max_speed * delta
		player.velocity.y = min(player.velocity.y, 0)
	elif player.velocity.y > 0:
		player.velocity.y -= player.move_deceleration * player.max_speed * delta
		player.velocity.y = max(player.velocity.y, 0)
	
	player.move_and_slide()


func flip_sprite():
	if player.is_stuck_right():
		if player.has_input_up():
			player.flip_sprite("r")
		elif player.has_input_down():
			player.flip_sprite("l")
	elif player.is_stuck_left():
		if player.has_input_up():
			player.flip_sprite("l")
		elif player.has_input_down():
			player.flip_sprite("r")


func cap_velocity():
	player.velocity.y = clampf(player.velocity.y, -player.max_speed, player.max_speed)

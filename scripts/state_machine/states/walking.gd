extends PlayerState

func _enter(_msg := {}):
	# Set animation
	player.set_animation("Walking")


func _physics_update(delta: float) -> void:
	# Transition to idle
	if not player.has_input_left_right() and player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	# This is used for breakable ground, or when the player goes off the ground
	if not player.is_on_floor() and not player.is_colliding_down():
		if player.was_on_floor:
			player.coyote_timer.start()
		
		state_machine.transition_to("Air")
		return
	
	# Transition to Jumping
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		player.set_current_down("b")
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
	
	
	"""
		Change from ground to walls
	"""
	if player.is_on_floor() and player.has_input_up():
		# Colliding with left wall
		if player.is_colliding_left():
			player.set_current_down("l")
			player.stick_to_surface("l")
			state_machine.transition_to("WallWalking")
		
		# Colliding with right wall
		elif player.is_colliding_right():
			player.set_current_down("r")
			player.stick_to_surface("r")
			state_machine.transition_to("WallWalking")
	
	move(player.get_x_input(), delta)
	
	flip_sprite()
	
	cap_velocity()


func move(direction, delta):
	# Accelerate
	if direction:
		player.velocity.x += direction * player.move_acceleration * player.max_speed * delta
	# Decelerate
	elif player.velocity.x < 0:
		player.velocity.x += player.move_deceleration * player.max_speed * delta
		player.velocity.x = min(player.velocity.x, 0)
	elif player.velocity.x > 0:
		player.velocity.x -= player.move_deceleration * player.max_speed * delta
		player.velocity.x = max(player.velocity.x, 0)

	player.was_on_floor = player.is_on_floor()
	
	player.move_and_slide()


func flip_sprite():
	if player.has_input_left():
		player.flip_sprite("l")
	elif player.has_input_right():
		player.flip_sprite("r")


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)

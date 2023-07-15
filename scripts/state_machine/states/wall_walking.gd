extends PlayerState


func _enter(_msg := {}):
	# Play animation
	player.set_animation("Walking")


func _physics_update(delta: float) -> void:
	# Transition to Idle
	if not player.has_input_up_down() and not player.is_y_stationary():
		state_machine.transition_to("Idle")
	
	# Transition to Air (without jump)
	
	# Transition to air (with jump)
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		player.set_current_down("b")
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
	
	"""
		Change from walls to ground or ceiling
	"""
	if player.has_input_right() and player.is_stuck_left():
		# Colliding with ceiling
		if player.is_colliding_left():
			player.set_current_down("t")
			player.stick_to_surface("t")
			state_machine.transition_to("CeilingWalk")
		
		# Colliding with ground
		elif player.is_colliding_right():
			player.set_current_down("b")
			player.stick_to_surface("b")
			state_machine.transition_to("Walking")
	elif player.has_input_left() and player.is_stuck_right():
		# Colliding with ground
		if player.is_colliding_left():
			player.set_current_down("b")
			state_machine.transition_to("Walking")
		
		# Colliding with ceiling
		elif player.is_colliding_right():
			player.set_current_down("t")
			player.stick_to_surface("t")
			state_machine.transition_to("CeilingWalk")
	
	move(player.get_y_input(), delta)
	
	flip_sprite()
	
	cap_velocity()


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

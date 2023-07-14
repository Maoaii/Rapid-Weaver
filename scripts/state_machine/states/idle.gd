extends PlayerState


func _physics_update(_delta: float) -> void:
	# Play animation
	player.set_animation("Idle")
	
	# Jump from idle
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		player.set_current_down("b")
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
	
	# If any surface we're standing on breaks, transition to air
	if not player.is_colliding_down():
		player.set_current_down("b") 
		state_machine.transition_to("Air")
	
	"""
		Walk on surfaces we're standing on
	"""
	if player.is_on_floor() and player.has_input_left_right():
		state_machine.transition_to("Walking")
	
	if player.is_on_ceiling() and player.has_input_left_right():
		state_machine.transition_to("CeilingWalk")
	
	if player.is_on_wall() and player.has_input_up_down():
		state_machine.transition_to("WallWalking")
	
	"""
		Change from ceiling to walls
	"""
	if player.is_on_ceiling() and player.has_input_down():
		# Colliding with right wall
		if player.is_colliding_left():
			player.set_current_down("r")
			player.stick_to_surface("r")
			state_machine.transition_to("WallWalking")
		
		# Colliding with left wall
		elif player.is_colliding_right():
			player.set_current_down("l")
			player.stick_to_surface("l")
			state_machine.transition_to("WallWalking")
	
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
	
	"""
		Change from walls to ground and ceiling
	"""
	if player.is_on_wall() and player.has_input_left_right():
		# Player is on left wall
		if player.is_stuck_left():
			
			# Colliding with the ceiling
			if player.is_colliding_left():
				player.set_current_down("t")
				player.stick_to_surface("t")
				state_machine.transition_to("CeilingWalk")
			
			# Colliding with the ground
			elif player.is_colliding_right():
				player.set_current_down("b")
				state_machine.transition_to("Walking")
		
		# Player is on right wall
		elif player.is_stuck_right():
			
			# Colliding with the ground
			if player.is_colliding_left():
				player.set_current_down("b")
				state_machine.transition_to("Walking")
			
			# Colliding with the ceiling
			elif player.is_colliding_right():
				player.set_current_down("t")
				player.stick_to_surface("t")
				state_machine.transition_to("CeilingWalk")

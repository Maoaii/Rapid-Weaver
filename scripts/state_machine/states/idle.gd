extends PlayerState


func _enter(_msg := {}) -> void:
	# Play animation
	player.set_animation("Idle")

func _physics_update(_delta: float) -> void:
	"""
		Transition to zooming
	"""
	if Input.is_action_just_pressed("shoot_web") and player.web_is_colliding():
		state_machine.transition_to("Zooming", 
			{"position": player.get_web_collision_pos()})
		return
	
	"""
		Jump from idle
	"""
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down: Vector2 = player.current_down
		
		state_machine.transition_to("Air",
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
		return
	
	"""
		If any surface we're standing on breaks, transition to air
	"""
	if not player.is_colliding_down():
		state_machine.transition_to("Air")
		return
	
	"""
		Walk on surfaces we're standing on
	"""
	if player.is_stuck_down() and player.has_input_left_right():
		state_machine.transition_to("Walking")
		return
	
	if player.is_stuck_up() and player.has_input_left_right():
		state_machine.transition_to("CeilingWalk")
		return
	
	if (player.is_stuck_left() or player.is_stuck_right()) and player.has_input_up_down():
		state_machine.transition_to("WallWalking")
		return
	
	"""
		Change from ceiling to walls
	"""
	if player.is_on_ceiling() and player.has_input_down():
		# Colliding with right wall
		if player.is_colliding_left():
			state_machine.transition_to("WallWalking")
			return
		
		# Colliding with left wall
		elif player.is_colliding_right():
			state_machine.transition_to("WallWalking")
			return
	
	"""
		Change from ground to walls
	"""
	if player.is_on_floor() and player.has_input_up():
		# Colliding with left wall
		if player.is_colliding_left():
			state_machine.transition_to("WallWalking")
			return
		
		# Colliding with right wall
		elif player.is_colliding_right():
			state_machine.transition_to("WallWalking")
			return
	
	"""
		Change from walls to ground and ceiling
	"""
	if player.is_stuck_left() and player.has_input_right():
		if player.is_colliding_left():
			state_machine.transition_to("CeilingWalk")
			return
		elif player.is_colliding_right():
			state_machine.transition_to("Walking")
			return
		
	elif player.is_stuck_right() and player.has_input_left():
		
		if player.is_colliding_left():
			state_machine.transition_to("Walking")
			return
		elif player.is_colliding_right():
			state_machine.transition_to("CeilingWalk")
			return

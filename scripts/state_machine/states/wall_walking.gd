extends PlayerState


func _enter(_msg := {}):
	# Play animation
	player.set_animation("Walking")
	
	"""
		Set direction for gravity to work in
	"""
	if player.is_stuck_left() or player.is_stuck_right():
		if player.is_stuck_left():
			player.set_current_down(Global.DIRECTIONS.LEFT)
			player.stick_to_surface(Global.DIRECTIONS.LEFT)
		else:
			player.set_current_down(Global.DIRECTIONS.RIGHT)
			player.stick_to_surface(Global.DIRECTIONS.RIGHT)
	elif not player.is_on_ceiling():
		if player.is_colliding_right():
			player.set_current_down(Global.DIRECTIONS.RIGHT)
			player.stick_to_surface(Global.DIRECTIONS.RIGHT)
		else:
			player.set_current_down(Global.DIRECTIONS.LEFT)
			player.stick_to_surface(Global.DIRECTIONS.LEFT)
	else:
		if player.is_colliding_right():
			player.set_current_down(Global.DIRECTIONS.LEFT)
			player.stick_to_surface(Global.DIRECTIONS.LEFT)
		else:
			player.set_current_down(Global.DIRECTIONS.RIGHT)
			player.stick_to_surface(Global.DIRECTIONS.RIGHT)


func _physics_update(delta: float) -> void:
	player.move_y(delta)
	player.flip_sprite_wall()
	
	"""
		Transition to zooming
	"""
	if Input.is_action_just_pressed("shoot_web") and player.web_is_colliding():
		state_machine.transition_to("Zooming", 
			{"position": player.get_web_collision_pos()})
		return
	
	"""
		Transition to Idle
	"""
	if not player.has_input_up_down() and player.is_y_stationary():
		state_machine.transition_to("Idle")
		return
	
	"""
		Transition to Air (without jump)
	"""
	if not player.is_colliding_down() and not player.is_on_wall():
		state_machine.transition_to("Air")
		return
	
	"""
		Transition to air (with jump)
	"""
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
		
		return 
	
	"""
		Change from walls to ground or ceiling
	"""
	if player.has_input_right() and player.is_stuck_left():
		# Colliding with ceiling
		if player.is_colliding_left():
			state_machine.transition_to("CeilingWalk")
			return
		
		# Colliding with ground
		elif player.is_colliding_right():
			state_machine.transition_to("Walking")
			return
	elif player.has_input_left() and player.is_stuck_right():
		# Colliding with ground
		if player.is_colliding_left():
			state_machine.transition_to("Walking")
			return
		
		# Colliding with ceiling
		elif player.is_colliding_right():
			state_machine.transition_to("CeilingWalk")
			return


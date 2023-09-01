extends PlayerState


func _enter(_msg := {}) -> void:
	# Play animation
	player.set_animation("Walking")
	
	if player.is_stuck_up():
		if player.collision_detector.is_colliding_right():
			player.set_current_down(Global.DIRECTIONS.LEFT)
			player.stick_to_surface(Global.DIRECTIONS.LEFT)
		elif player.collision_detector.is_colliding_left():
			player.set_current_down(Global.DIRECTIONS.RIGHT)
			player.stick_to_surface(Global.DIRECTIONS.RIGHT)
	elif player.is_stuck_down():
		if player.collision_detector.is_colliding_right():
			player.set_current_down(Global.DIRECTIONS.RIGHT)
			player.stick_to_surface(Global.DIRECTIONS.RIGHT)
		elif player.collision_detector.is_colliding_left():
			player.set_current_down(Global.DIRECTIONS.LEFT)
			player.stick_to_surface(Global.DIRECTIONS.LEFT)


func _physics_update(delta: float) -> void:
	player.move_y(delta)
	player.flip_sprite_wall()
	
	"""
		Transition to zooming
	"""
	if Input.is_action_just_pressed("shoot_web") and player.web_is_colliding():
		if player.web_travel_time:
			player.shoot_web()._on_destination_reached.connect(state_machine.transition_to)
		else:
			var collider = player.web.get_collider()
			var target_position = player.get_web_collision_pos()
			state_machine.transition_to("Zooming", {
				"position": target_position,
				"collider": collider
			})
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
	if not player.collision_detector.is_colliding_down() and not player.is_on_wall():
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
		if player.collision_detector.is_colliding_left():
			state_machine.transition_to("CeilingWalk")
			return
		
		# Colliding with ground
		elif player.collision_detector.is_colliding_right():
			state_machine.transition_to("Walking")
			return
	elif player.has_input_left() and player.is_stuck_right():
		# Colliding with ground
		if player.collision_detector.is_colliding_left():
			state_machine.transition_to("Walking")
			return
		
		# Colliding with ceiling
		elif player.collision_detector.is_colliding_right():
			state_machine.transition_to("CeilingWalk")
			return


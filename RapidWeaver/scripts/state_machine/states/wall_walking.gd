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
	if Input.is_action_just_pressed("shoot_web"):
		if player.web_travel_time:
			var hook = player.shoot_web()
			hook._on_destination_reached.connect(check_web_collisions)
			player.web.set_hook(hook)
		else:
			player.web.set_last_collider()
			player.web.set_last_target_position()
			state_machine.transition_to("Zooming", {
				"position": player.web.get_last_target_position(),
				"collider": player.web.get_last_collider()
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

func check_web_collisions(collisions, stop_position) -> void:
	if len(collisions) > 0:
		state_machine.transition_to("Zooming", {
			"position": stop_position,
			"collider": collisions[0]
		})
		return

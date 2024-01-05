extends PlayerState

func _enter(_msg := {}) -> void:
	# Set direction for gravity to work in
	player.set_current_down(Global.DIRECTIONS.UP)
	player.stick_to_surface(Global.DIRECTIONS.UP)
	
	# Play animation
	player.set_animation("Walking")
	

func _physics_update(delta: float) -> void:
	"""
		Transition to dead
	"""
	if player.dead == true:
		state_machine.transition_to("Dead")
		return
	
	player.move_x(delta)
	player.flip_sprite_ceiling()
	
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
	if not player.has_input_left_right() and player.is_x_stationary():
		state_machine.transition_to("Idle")
		return
	
	"""
		Transition to Air (without jump)
	"""
	if not player.collision_detector.is_colliding_down() and not player.is_on_ceiling():
		state_machine.transition_to("Air")
		return
	
	"""
		Transition to Air (with jump)
	"""
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		
		state_machine.transition_to("Air", 
			{"jump": true, 
			"direction": (tmp_current_down * Vector2(-1, -1))})
		return
	
	"""
		Change from ceiling to walls
	"""
	if player.has_input_down():
		# Colliding with rifht wall
		if player.collision_detector.is_colliding_left():
			state_machine.transition_to("WallWalking")
			return
		
		# Colliding with left wall
		elif player.collision_detector.is_colliding_right():
			state_machine.transition_to("WallWalking")
			return


func check_web_collisions(collisions, stop_position) -> void:
	if len(collisions) > 0:
		state_machine.transition_to("Zooming", {
			"position": stop_position,
			"collider": collisions[0]
		})
		return

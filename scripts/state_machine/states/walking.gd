extends PlayerState

func _enter(_msg := {}):
	# Set animation
	player.set_animation("Walking")


func _physics_update(delta: float) -> void:
	# Transition to idle
	if not player.has_input_left_right() and player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	if not player.is_colliding_down() and not player.is_on_floor():
		player.set_current_down("b")
		state_machine.transition_to("Air")
	
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
	
	player.move_x(delta)
	
	player.flip_sprite_air_ground()

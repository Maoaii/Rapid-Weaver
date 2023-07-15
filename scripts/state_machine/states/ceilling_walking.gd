extends PlayerState

func _enter(_msg := {}):
	# Set direction for gravity to work in
	player.set_current_down("t")
	
	# Play animation
	player.set_animation("Walking")
	

func _physics_update(delta: float) -> void:
	# Transition to Idle
	if not player.has_input_left_right() and player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	# Transition to Air (without jump)
	if not player.is_colliding_down() and not player.is_on_ceiling():
		player.set_current_down("b")
		state_machine.transition_to("Air")
	
	# Transition to Air (with jump)
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		player.set_current_down("b")
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
	
	"""
		Change from ceiling to walls
	"""
	if player.has_input_down():
		# Colliding with rifht wall
		if player.is_colliding_left():
			player.set_current_down("r")
			player.stick_to_surface("r")
			state_machine.transition_to("WallWalking")
		
		# Colliding with left wall
		elif player.is_colliding_right():
			player.set_current_down("l")
			player.stick_to_surface("l")
			state_machine.transition_to("WallWalking")
	
	player.move_x(delta)
	
	player.flip_sprite_ceiling()

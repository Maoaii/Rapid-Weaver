extends PlayerState


func _enter(_msg := {}):
	# Play animation
	player.set_animation("Walking")


func _physics_update(delta: float) -> void:
	# Transition to Idle
	if not player.has_input_up_down() and player.is_y_stationary():
		state_machine.transition_to("Idle")
	
	# Transition to Air (without jump)
	if not player.is_colliding_down() and not player.is_on_wall():
		player.set_current_down("b")
		state_machine.transition_to("Air")
	
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
	
	player.move_y(delta)
	
	player.flip_sprite_wall()


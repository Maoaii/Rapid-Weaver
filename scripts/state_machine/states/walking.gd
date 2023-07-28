extends PlayerState

func _enter(_msg := {}):
	# Set direction for gravity to work in
	player.set_current_down("b")
	
	# Set animation
	player.set_animation("Walking")


func _physics_update(delta: float) -> void:
	player.move_x(delta)
	player.flip_sprite_air_ground()
	
	"""
		Transition to Idle
	"""
	if not player.has_input_left_right() and player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	"""
		Transition to Air
	"""
	if not player.is_colliding_down() and not player.is_on_floor():
		state_machine.transition_to("Air")
	
	# This is used for breakable ground, or when the player goes off the ground
	if not player.is_on_floor() and not player.is_colliding_down():
		if player.was_on_floor:
			player.coyote_timer.start()
		
		state_machine.transition_to("Air")
		return
	
	"""
		Transition to Jumping
	"""
	if Input.is_action_just_pressed("jump"):
		var tmp_current_down = player.current_down
		
		state_machine.transition_to("Air", 
			{"jump": true, "direction": (tmp_current_down * Vector2(-1, -1))})
	
	"""
		Change from ground to walls
	"""
	if player.is_on_floor() and player.has_input_up() and player.is_colliding_left() or player.is_colliding_right():
		state_machine.transition_to("WallWalking")

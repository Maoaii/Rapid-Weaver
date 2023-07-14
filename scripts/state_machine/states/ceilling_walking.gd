extends PlayerState

func _enter(_msg := {}):
	# Play animation
	player.set_animation("Walking")

func _physics_update(delta: float) -> void:
	# Transition to idle
	if player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	# Transition to Air (with jump)
	if Input.is_action_just_pressed("jump"):
		player.set_current_down("b")
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to Air (without jump)
	if not player.is_colliding_down() and not player.is_on_ceiling():
		player.set_current_down("b")
		state_machine.transition_to("Air")
	
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
	
	move(player.get_x_input(), delta)
	
	flip_sprite()
	
	cap_velocity()

func move(direction, delta):
	# Accelerate
	if direction:
		player.velocity.x += direction * player.move_acceleration * player.max_speed * delta
	# Decelerate
	elif player.velocity.x < 0:
		player.velocity.x += player.move_deceleration * player.max_speed * delta
		player.velocity.x = min(player.velocity.x, 0)
	elif player.velocity.x > 0:
		player.velocity.x -= player.move_deceleration * player.max_speed * delta
		player.velocity.x = max(player.velocity.x, 0)
	
	player.move_and_slide()


func flip_sprite():
	if player.has_input_right():
		player.flip_sprite("l")
	elif player.has_input_left():
		player.flip_sprite("r")


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)

extends PlayerState

func _physics_process(delta: float) -> void:
	handle_jump()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		# Coyote time
		if player.is_on_floor() or !player.coyote_timer.is_stopped():
			player.velocity.y = player.jump_velocity
		elif !player.is_on_floor():
			player.jump_buffer_timer.start()
	
	# Jump buffer
	if player.is_on_floor() and !player.jump_buffer_timer.is_stopped():
		player.velocity.y = player.jump_velocity
	
	# Variable jump height
	if Input.is_action_just_released("jump"):
		player.velocity.y *= 0.5

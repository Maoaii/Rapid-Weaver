extends PlayerState


func _enter(msg := {}) -> void:
	if msg.has("jump"):
		handle_jump()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_update(delta: float) -> void:
	player.is_sticky = false
	
	move(player.x_direction, delta)
	
	cap_velocity()
	
	handle_jump()
	
	# Stick to ceiling
	if player.is_colliding_up and player.y_direction == Vector2.UP.y:
		state_machine.transition_to("CeilingWalk") 
	
	# Stick to walls
	if player.is_colliding_left and player.x_direction == Vector2.LEFT.x:
		state_machine.transition_to("WallWalking") 
	if player.is_colliding_right and player.x_direction == Vector2.RIGHT.x:
		state_machine.transition_to("WallWalking") 
	
	# Landing
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		state_machine.transition_to("Idle" if player.velocity.x == 0 else "Walking")


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor() or player.is_sticky or not player.coyote_timer.is_stopped():
			# Different jumping directions based on stickiness
<<<<<<< Updated upstream
			if player.sticky_down.is_colliding() or not player.coyote_timer.is_stopped():
=======
			if player.is_colliding_down or not player.coyote_timer.is_stopped():
>>>>>>> Stashed changes
				player.velocity.y = player.jump_velocity
			elif player.sticky_up.is_colliding():
				player.velocity.y = -player.jump_velocity
			elif player.sticky_right.is_colliding():
				player.velocity = Vector2(player.jump_velocity, -player.wall_jump_velocity)
			elif player.sticky_left.is_colliding():
				player.velocity = Vector2(-player.jump_velocity, -player.wall_jump_velocity)
		elif not player.is_on_floor():
			player.jump_buffer_timer.start()
	
	# Jump buffer
	if player.is_on_floor() and not player.jump_buffer_timer.is_stopped():
		player.velocity.y = player.jump_velocity
	
	# Variable jump height
	if Input.is_action_just_released("jump") and player.velocity.y < 0.0:
		player.velocity.y *= 0.5


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
	
	player.was_on_floor = player.is_on_floor()
	
	player.move_and_slide()


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)

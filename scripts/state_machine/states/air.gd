extends PlayerState


func _enter(msg := {}) -> void:
	if msg.has("jump"):
		handle_jump()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_update(delta: float) -> void:
	player.is_sticky = false
	
	# Play animation
	# !TODO: change to Air
	#player.set_animation("Idle")
	
	move(player.get_x_input(), delta)
	
	flip_sprite()
	
	cap_velocity()
	
	handle_jump()
	
	# Stick to ceiling
	if player.is_on_ceiling() and player.has_input_up():
		player.set_current_down(Vector2.UP)
		state_machine.transition_to("CeilingWalk") 
	
	# Stick to walls
	if player.is_colliding_left() and player.has_input_left():
		player.set_current_down(Vector2.LEFT)
		state_machine.transition_to("WallWalking")
	
	if player.is_colliding_right() and player.has_input_right():
		player.set_current_down(Vector2.RIGHT)
		state_machine.transition_to("WallWalking") 
	
	# Landing
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Idle" if player.is_x_stationary() else "Walking")


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor() or player.is_sticky or not player.coyote_timer.is_stopped():
			# Different jumping directions based on stickiness
			if player.is_on_floor() or not player.coyote_timer.is_stopped():
				player.velocity.y = player.jump_velocity
			elif player.is_colliding_up:
				player.velocity.y = -player.jump_velocity
			elif player.is_colliding_right:
				player.velocity = Vector2(player.jump_velocity, -player.wall_jump_velocity)
			elif player.is_colliding_left:
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


func flip_sprite():
	if player.has_input_left():
		player.flip_sprite("l")
	elif player.has_input_right():
		player.flip_sprite("r")


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)

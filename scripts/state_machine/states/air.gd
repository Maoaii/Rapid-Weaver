extends PlayerState

const JUMP_DIRECTIONS = {
	Vector2.UP: "u",
	Vector2.RIGHT: "r",
	Vector2.DOWN: "d",
	Vector2.LEFT: "l"
}

func _enter(msg := {}) -> void:
	
	if msg.has("jump"):
		handle_jump(JUMP_DIRECTIONS.get(msg.get("direction")))
	
	# Play animation
	# !TODO: change to Air
	#player.set_animation("Idle")


func _physics_update(delta: float) -> void:
	"""
		Stick to the ceiling
	"""
	if player.is_on_ceiling() and player.has_input_up():
		player.set_current_down("t")
		player.stick_to_surface("t")
		state_machine.transition_to("CeilingWalk")
	
	"""
		Stick to the walls
	"""
	if player.is_colliding_left() and player.has_input_left():
		player.set_current_down("l")
		player.stick_to_surface("l")
		state_machine.transition_to("WallWalking")
	
	if player.is_colliding_right() and player.has_input_right():
		player.set_current_down("r")
		player.stick_to_surface("r")
		state_machine.transition_to("WallWalking")
	
	"""
		Stick to the ground
	"""
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		player.set_current_down("b")
		state_machine.transition_to("Walking")
	
	move(player.get_x_input(), delta)
	
	flip_sprite()
	
	cap_velocity()
	
	handle_jump(JUMP_DIRECTIONS.get(Vector2.UP))


func handle_jump(direction):
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor() or not player.coyote_timer.is_stopped():
			player.velocity.y = player.jump_velocity
		elif player.is_on_ceiling() or player.is_on_wall():
			match direction:
				"d":
					# Jump down
					player.velocity.y = -player.jump_velocity
					
				"r":
					# Jump right
					player.velocity = Vector2(-player.jump_velocity, -player.wall_jump_velocity)
					
				"l":
					# Jump left
					player.velocity = Vector2(player.jump_velocity, -player.wall_jump_velocity)
		else:
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

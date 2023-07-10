extends PlayerState


func _enter(msg := {}) -> void:
	if msg.has("jump"): 
		handle_jump()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_update(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	move(direction, delta)
	
	cap_velocity()
	
	handle_jump()
	
	# Landing
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		if player.velocity.x == 0:
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walking")


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		# Coyote time
		if player.is_on_floor() or not player.coyote_timer.is_stopped():
			player.velocity.y = player.jump_velocity
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
	if player.velocity.x > player.max_speed:
		player.velocity.x = player.max_speed
	elif player.velocity.x < -player.max_speed:
		player.velocity.x = -player.max_speed

extends PlayerState

func _enter(_msg := {}):
	player.is_sticky = true

func _physics_update(delta: float) -> void:
	move(player.get_x_input(), delta)
	
	flip_sprite()
	
	cap_velocity()
	
	# Transition to idle
	if player.is_x_stationary():
		state_machine.transition_to("Idle")
	
	
	# Transition to Air (with jump)
	if Input.is_action_just_pressed("jump"):
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to Air (without jump)
	if not player.is_on_ceiling():
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Air")
	
	if player.is_colliding_left() and player.has_input_down():
		player.set_current_down(Vector2.RIGHT)
		state_machine.transition_to("WallWalking")
		
	if player.is_colliding_right() and player.has_input_down():
		player.set_current_down(Vector2.LEFT)
		state_machine.transition_to("WallWalking")

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

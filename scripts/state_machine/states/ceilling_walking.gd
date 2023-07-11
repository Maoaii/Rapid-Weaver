extends PlayerState

func _enter(msg := {}):
	player.is_sticky = true

func _physics_update(delta: float) -> void:
	move(player.x_direction, delta)
	
	cap_velocity()
	
	# Transition to idle
	if player.velocity.x == Vector2.ZERO.x:
		state_machine.transition_to("Idle")
	
	# Transition to Wall walking
	if (player.is_colliding_left or player.is_colliding_right) and player.y_direction:
		state_machine.transition_to("WallWalking")
	
	# Transition to Air (with jump)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to Air (without jump)
	if not player.is_colliding_up:
		state_machine.transition_to("Air")

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


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)

extends PlayerState

func _enter(msg := {}):
	player.is_sticky = false

func _physics_update(delta: float) -> void:
	# This is used for breakable ground, or when the player goes off the ground
	if not player.is_on_floor():
		if player.was_on_floor:
			player.coyote_timer.start()
		state_machine.transition_to("Air")
		return
	
	# Coliders
	var colliding_left = player.sticky_left.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	
	# Movement input
	var x_direction = Input.get_axis("left", "right")
	var y_direction = Input.get_axis("up", "down")
	
	move(x_direction, delta)
	
	cap_velocity()
	
	# Transition to Jumping
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to idle
	if player.velocity.x == 0:
		state_machine.transition_to("Idle")
	
	# Transition to wall walking
	if (colliding_left or colliding_right) and y_direction:
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

	player.was_on_floor = player.is_on_floor()
	
	player.move_and_slide()


func cap_velocity():
	player.velocity.x = clampf(player.velocity.x, -player.max_speed, player.max_speed)


func handle_coyote_time():
	if player.was_on_floor and !player.is_on_floor():
		player.coyote_timer.start()

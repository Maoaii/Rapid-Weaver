extends PlayerState

func _enter(msg := {}):
	player.is_sticky = false

func _physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	var direction = Input.get_axis("left", "right")
	move(direction, delta)
	
	cap_velocity()
	
	handle_coyote_time()
	
	# Transition to Jumping
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to idle
	if player.velocity.x == 0:
		state_machine.transition_to("Idle")
	
	# Transition to Wall walking
	direction = Input.get_axis("up", "down")
	var colliding_left = player.sticky_left.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	if (colliding_left or colliding_right) and direction:
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

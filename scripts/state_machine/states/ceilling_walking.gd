extends PlayerState

func _enter(msg := {}):
	player.is_sticky = true

func _physics_update(delta: float) -> void:
	# Colliders
	var x_direction = Input.get_axis("left", "right")
	var y_direction = Input.get_axis("up", "down")
	
	# Movement Input
	var colliding_up = player.sticky_up.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	var colliding_left = player.sticky_left.is_colliding()
	
	move(x_direction, delta)
	
	cap_velocity()
	
	# Transition to idle
	if player.velocity.x == 0:
		state_machine.transition_to("Idle")
	
	# Transition to Wall walking
	if (colliding_left or colliding_right) and y_direction:
		state_machine.transition_to("WallWalking")
	
	# Transition to Air (with jump)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to Air (without jump)
	if not colliding_up:
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

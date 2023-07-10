extends PlayerState


func _enter(msg := {}):
	player.is_sticky = true


func _physics_update(delta: float) -> void:
	# Colliders
	var colliding_up = player.sticky_up.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	var collider_down = player.sticky_down.is_colliding()
	var colliding_left = player.sticky_left.is_colliding()
	
	# Movement input
	var y_direction = Input.get_axis("up", "down")
	var x_direction = Input.get_axis("left", "right")
	
	move(y_direction, delta)
	
	cap_velocity()
	
	# Transition to idle
	if player.velocity.y == 0:
		state_machine.transition_to("Idle")
	
	# Transition to ground walk
	if collider_down and x_direction:
		state_machine.transition_to("Walking")
	
	# Transition to ceiling walk
	if colliding_up and x_direction:
		state_machine.transition_to("CeilingWalk")
	
	# Transition to air (with jump)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Transition to air (without jump)
	if not colliding_left and not colliding_right:
		state_machine.transition_to("Air")


func move(direction, delta):
	# Accelerate
	if direction:
		player.velocity.y += direction * player.move_acceleration * player.max_speed * delta
	# Decelerate
	elif player.velocity.y < 0:
		player.velocity.y += player.move_deceleration * player.max_speed * delta
		player.velocity.y = min(player.velocity.x, 0)
	elif player.velocity.y > 0:
		player.velocity.y -= player.move_deceleration * player.max_speed * delta
		player.velocity.y = max(player.velocity.x, 0)
	
	player.move_and_slide()

func cap_velocity():
	player.velocity.y = clampf(player.velocity.y, -player.max_speed, player.max_speed)

extends PlayerState


func _enter(msg := {}):
	player.is_sticky = true

func _physics_update(delta: float) -> void:
	var direction = Input.get_axis("up", "down")
	move(direction, delta)
	
	cap_velocity()
	
	direction = Input.get_axis("left", "right")
	var collider_down = player.sticky_down.is_colliding()
	
	if collider_down and direction:
		player.is_sticky = false
		state_machine.transition_to("Walking")
	
	# Transition to idle
	if player.velocity.y == 0:
		state_machine.transition_to("Idle")
	
	# Transition to air
	var colliding_left = player.sticky_left.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	if Input.is_action_just_pressed("jump") or (not colliding_left and not colliding_right):
		state_machine.transition_to("Air", {jump = true, direction = Vector2.RIGHT})
	
	

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

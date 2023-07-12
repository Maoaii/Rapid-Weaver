extends PlayerState


func _physics_update(_delta: float) -> void:
	# Play animation
	player.set_animation("Idle")
	
	# Jump from idle
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Move left and right on ground
	if (player.is_colliding_down or player.is_on_floor()) and player.x_direction:
		state_machine.transition_to("Walking")
	
	# Move left and right on ceiling
	if player.is_colliding_up and player.x_direction:
		state_machine.transition_to("CeilingWalk")
	
	# Move up and down in walls
	if (player.is_colliding_right or player.is_colliding_left) and player.y_direction:
		state_machine.transition_to("WallWalking")

extends PlayerState


func _physics_update(_delta: float) -> void:
	# Colliders
	var colliding_up = player.sticky_up.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	var collider_down = player.sticky_down.is_colliding()
	var colliding_left = player.sticky_left.is_colliding()
	
	# Input directions
	var x_direction = Input.get_axis("left", "right")
	var y_direction = Input.get_axis("up", "down")
	
	# Jump from idle
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Move left and right on ground
	if collider_down and x_direction:
		state_machine.transition_to("Walking")
	
	# Move left and right on ceiling
	if colliding_up and x_direction:
		state_machine.transition_to("CeilingWalk")
	
	# Move up and down in walls
	if (colliding_left or colliding_right) and y_direction:
		state_machine.transition_to("WallWalking")

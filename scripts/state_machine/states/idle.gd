extends PlayerState


func _physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	# Move left and right
	var direction = Input.get_axis("left", "right")
	var collider_down = player.sticky_down.is_colliding()
	if collider_down and direction:
		state_machine.transition_to("Walking")
	
	# Move up and down
	direction = Input.get_axis("up", "down")
	var colliding_left = player.sticky_left.is_colliding()
	var colliding_right = player.sticky_right.is_colliding()
	
	if (colliding_left or colliding_right) and direction:
		state_machine.transition_to("WallWalking")

extends PlayerState


func _physics_update(_delta: float) -> void:
	# Play animation
	player.set_animation("Idle")
	
	# Jump from idle
	if Input.is_action_just_pressed("jump"):
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Air", {jump = true})
	
	if not player.is_on_ceiling() and not player.is_on_floor() and not player.is_on_wall():
		player.set_current_down(Vector2.DOWN) 
		state_machine.transition_to("Air")
	
	# Walk on surfaces
	if player.is_on_floor() and player.has_input_left_right():
		state_machine.transition_to("Walking")
	
	if player.is_on_ceiling() and player.has_input_left_right():
		state_machine.transition_to("CeilingWalk")
	
	if player.is_on_wall() and player.has_input_up_down():
		state_machine.transition_to("WallWalking")
	
	
	if player.is_on_wall() and player.is_stuck_left() and player.has_input_up_down():
		player.velocity.y = 0
		state_machine.transition_to("WallWalking")
	
	if player.is_on_wall() and player.is_stuck_right() and player.has_input_up_down():
		player.velocity.y = 0
		state_machine.transition_to("WallWalking")
	
	if player.is_on_floor() and player.is_colliding_left() and player.has_input_up():
		player.set_current_down(Vector2.LEFT)
		state_machine.transition_to("WallWalking")
	
	if player.is_on_floor() and player.is_colliding_right() and player.has_input_up():
		player.set_current_down(Vector2.RIGHT)
		state_machine.transition_to("WallWalking")
	
	if player.is_on_ceiling() and player.is_colliding_left() and player.has_input_down():
		player.set_current_down (Vector2.LEFT)
		state_machine.transition_to("WallWalking")
	
	if player.is_on_ceiling() and player.is_colliding_right() and player.has_input_down():
		player.set_current_down(Vector2.RIGHT)
		state_machine.transition_to("WallWalking")
	
	if player.is_on_wall() and player.is_colliding_left() and player.has_input_left():
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Walking")
	
	if player.is_on_wall() and player.is_colliding_right() and player.has_input_right():
		player.set_current_down(Vector2.DOWN)
		state_machine.transition_to("Walking")
	
	if player.is_on_wall() and player.is_colliding_left() and player.has_input_right():
		player.set_current_down(Vector2.UP)
		state_machine.transition_to("CeilingWalk")
	
	if player.is_on_wall() and player.is_colliding_right() and player.has_input_left():
		player.set_current_down(Vector2.UP)
		state_machine.transition_to("CeilingWalk")

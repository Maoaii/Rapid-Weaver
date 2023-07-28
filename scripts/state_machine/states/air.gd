extends PlayerState

## Dictionary that maps vector directions to strings
const JUMP_DIRECTIONS = {
	Vector2.UP: Global.DIRECTIONS.UP,
	Vector2.RIGHT: Global.DIRECTIONS.RIGHT,
	Vector2.DOWN: Global.DIRECTIONS.DOWN,
	Vector2.LEFT: Global.DIRECTIONS.LEFT
}


func _enter(msg := {}) -> void:
	# Set direction for gravity to work in
	player.set_current_down(Global.DIRECTIONS.DOWN)
	
	# Play animation
	player.set_animation("Air")
	
	# Went to Air State with a jump
	if msg.has("jump"):
		player.handle_jump(JUMP_DIRECTIONS.get(msg.get("direction")))


func _physics_update(delta: float) -> void:
	player.move_x(delta)
	player.flip_sprite_air_ground()
	
	"""
		Transition to zooming
	"""
	if Input.is_action_just_pressed("shoot_web") and player.web_is_colliding():
		state_machine.transition_to("Zooming", 
			{"position": player.get_web_collision_pos()})
		return
	
	"""
		Stick to the ceiling
	"""
	if player.is_on_ceiling() and player.has_input_up():
		state_machine.transition_to("CeilingWalk")
		return
	
	"""
		Stick to the walls
	"""
	if player.is_colliding_left() and player.has_input_left():
		state_machine.transition_to("WallWalking")
		return
	
	if player.is_colliding_right() and player.has_input_right():
		state_machine.transition_to("WallWalking")
		return
	
	"""
		Stick to the ground
	"""
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		state_machine.transition_to("Walking")
		return
	
	"""
		Jump again
	"""
	if Input.is_action_just_pressed("jump"):
		player.handle_jump(Global.DIRECTIONS.UP)

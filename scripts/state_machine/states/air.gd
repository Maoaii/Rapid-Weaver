extends PlayerState

const JUMP_DIRECTIONS = {
	Vector2.UP: "u",
	Vector2.RIGHT: "r",
	Vector2.DOWN: "d",
	Vector2.LEFT: "l"
}

func _enter(msg := {}) -> void:
	# Set direction for gravity to work in
	player.set_current_down("b")
	
	if msg.has("jump"):
		player.handle_jump(JUMP_DIRECTIONS.get(msg.get("direction")))
	
	# Play animation
	# !TODO: change to Air
	#player.set_animation("Idle")


func _physics_update(delta: float) -> void:
	"""
		Stick to the ceiling
	"""
	if player.is_on_ceiling() and player.has_input_up():
		player.set_current_down("t")
		player.stick_to_surface("t")
		state_machine.transition_to("CeilingWalk")
	
	"""
		Stick to the walls
	"""
	if player.is_colliding_left() and player.has_input_left():
		player.set_current_down("l")
		player.stick_to_surface("l")
		state_machine.transition_to("WallWalking")
	
	if player.is_colliding_right() and player.has_input_right():
		player.set_current_down("r")
		player.stick_to_surface("r")
		state_machine.transition_to("WallWalking")
	
	"""
		Stick to the ground
	"""
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		player.set_current_down("b")
		state_machine.transition_to("Walking")
	
	player.move_x(delta)
	
	player.flip_sprite_air_ground()
	
	player.handle_jump(JUMP_DIRECTIONS.get(Vector2.UP))

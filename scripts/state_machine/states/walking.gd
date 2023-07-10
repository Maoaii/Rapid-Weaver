extends PlayerState


func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	move(direction, delta)
	
	cap_velocity()
	
	handle_coyote_time()
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jumping")

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
	if player.velocity.x > player.max_speed:
		player.velocity.x = player.max_speed
	elif player.velocity.x < -player.max_speed:
		player.velocity.x = -player.max_speed


func handle_coyote_time():
	if player.was_on_floor and !player.is_on_floor():
		player.coyote_timer.start()

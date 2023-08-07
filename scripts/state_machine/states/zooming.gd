extends PlayerState

## Stores the current zooming position
var zooming_pos: Vector2
## Stores a temporary zooming position if tried to zoom while zooming
var tmp_zooming_pos: Vector2


func _enter(msg := {}) -> void:
	player.set_current_down(Global.DIRECTIONS.DOWN)
	
	player.set_animation("Zooming")
	
	zooming_pos = msg.get("position")
	
	# Disable gravity while zooming
	player.toggle_gravity()
	
	# Disable colliders while leaving the surface
	player.disable_colliders()
	
	# Make zooming not physics based
	if player.is_simple_zooming():
		player.reset_velocity()
	
	# Update player zooming variable (stops player from spamming zoom)
	player.zooming = true
	
	# Reset sprite horizontal flip
	player.reset_horizontal_flip()


func _exit() -> void:
	# Enable gravity when transitioning to another state
	player.toggle_gravity()
	
	# Update player zooming variable (stops player from spamming zoom)
	player.zooming = false
	
	# Remove all web drawings
	player.remove_web()
	
	# Reset sprite rotation
	player.reset_sprite_rotation()
	
	# Play squash animation
	player.play_squash_animation()


func _physics_update(delta: float) -> void:
	# Rotate sprite to match web collided position
	player.sprite_look_at(zooming_pos)
	
	# Draw web from player to zooming point
	player.draw_web(zooming_pos)
	
	# Move player to zooming position
	player.velocity += player.position.direction_to(zooming_pos) * player.get_zooming_acceleration() * player.get_zooming_max_speed() * delta
	
	# If player collided with a surface
	if player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling():
		# If buffer timer is on
		if not player.zoom_buffer_timer.is_stopped():
			state_machine.transition_to("Zooming", 
				{"position": tmp_zooming_pos})
			return
		else:
			# Enable colliders to decide which surface was collided with
			player.enable_colliders()
			
			if player.is_colliding_up():
				state_machine.transition_to("CeilingWalk")
				return
			elif player.is_colliding_right() or player.is_colliding_left():
				state_machine.transition_to("WallWalking")
				return
			elif player.is_colliding_down():
				state_machine.transition_to("Walking")
				return
	
	# In case the player tries to shoot the web but hasn't touched a surface,
	# yet, start buffer timer
	elif Input.is_action_just_pressed("shoot_web"):
		player.zoom_buffer_timer.start()
		tmp_zooming_pos = player.get_web_collision_pos()

extends PlayerState

## Stores the current zooming position
var zooming_pos: Vector2
## Stores a temporary zooming position if tried to zoom while zooming
var tmp_zooming_pos: Vector2

var moving_collider: Node2D
var destructable_collider: Destructable
var distance_from_pos: Vector2

func _enter(msg := {}) -> void:
	if msg.has("collider"):
		if msg.get("collider").is_in_group("Moving"):
			moving_collider = msg.get("collider")
			distance_from_pos = moving_collider.global_position - msg.get("position")
		
		if msg.get("collider").is_in_group("Destructable"):
			destructable_collider = msg.get("collider")
			destructable_collider._on_destroyed.connect(detach_web)
	
	player.set_current_down(Global.DIRECTIONS.DOWN)
	
	player.set_animation("Zooming")
	
	zooming_pos = msg.get("position")
	
	# Disable gravity while zooming
	player.toggle_gravity()
	
	# Disable colliders while leaving the surface
	player.collision_detector.disable_colliders()
	
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
	
	# Enable colliders when exiting zoom
	player.collision_detector.enable_colliders()
	
	if destructable_collider:
		destructable_collider._on_destroyed.disconnect(detach_web)
	
	moving_collider = null
	destructable_collider = null


func _physics_update(delta: float) -> void:
	"""
		Transition to dead
	"""
	if player.dead == true:
		state_machine.transition_to("Dead")
		return
	
	# Rotate sprite to match web collided position
	player.sprite_look_at(zooming_pos)
	
	# Draw web from player to zooming point
	player.draw_web(zooming_pos)
	
	if moving_collider:
		var new_distance_from_pos = moving_collider.global_position - zooming_pos
		#var speed = Vector2(abs(new_distance_from_pos.x) - abs(distance_from_pos.x), abs(new_distance_from_pos.y) - abs(distance_from_pos.y))
		var speed = new_distance_from_pos - distance_from_pos
		#distance_from_pos = new_distance_from_pos
		zooming_pos += speed
		
	
	# Move player to zooming position
	player.velocity += player.position.direction_to(zooming_pos) * player.get_zooming_acceleration() * player.get_zooming_max_speed() * delta
	
	# If player collided with a surface
	if player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling():
		# If buffer timer is on
		if not player.zoom_buffer_timer.is_stopped():
			if player.web_travel_time:
				var hook = player.shoot_web()
				hook._on_destination_reached.connect(check_web_collisions)
				player.web.set_hook(hook)
			else:
				player.web.set_last_collider()
				player.web.set_last_target_position()
				state_machine.transition_to("Zooming", {
					"position": player.web.get_last_target_position(),
					"collider": player.web.get_last_collider()
				})
				return
		else:
			# Enable colliders to decide which surface was collided with
			player.collision_detector.enable_colliders()
			
			if player.collision_detector.is_colliding_up():
				state_machine.transition_to("CeilingWalk")
				return
			elif player.collision_detector.is_colliding_right() or player.collision_detector.is_colliding_left():
				state_machine.transition_to("WallWalking")
				return
			elif player.collision_detector.is_colliding_down():
				state_machine.transition_to("Walking")
				return
	
	# In case the player tries to shoot the web but hasn't touched a surface,
	# yet, start buffer timer
	elif Input.is_action_just_pressed("shoot_web"):
		player.zoom_buffer_timer.start()
		tmp_zooming_pos = player.get_web_collision_pos()
	
	if player.web_release and Input.is_action_just_released("shoot_web"):
		state_machine.transition_to("Air", {"momentum": player.velocity})


func detach_web() -> void:
	state_machine.transition_to("Air", {"momentum": player.velocity})


func check_web_collisions(collisions, stop_position) -> void:
	if len(collisions) > 0:
		state_machine.transition_to("Zooming", {
			"position": stop_position,
			"collider": collisions[0]
		})
		return

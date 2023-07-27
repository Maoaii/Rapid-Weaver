extends PlayerState

var zooming_pos: Vector2
var tmp_zooming_pos: Vector2
var hook: Area2D

func _enter(msg := {}) -> void:
	player.set_current_down("b")
	
	zooming_pos = msg.get("position")
	
	# Disable gravity
	player.toggle_gravity()
	
	# Disable colliders
	player.disable_colliders()
	
	# Make zooming not physics based
	if player.is_simple_zooming():
		player.velocity = Vector2.ZERO
	
	player.zooming = true


func _exit() -> void:
	# Enable gravity
	player.toggle_gravity()
	
	player.zooming = false


func _physics_update(delta: float) -> void:
	player.velocity += player.position.direction_to(zooming_pos) * player.get_zooming_acceleration() * player.get_zooming_max_speed() * delta
	
	if Input.is_action_just_pressed("shoot_web") and not (player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling()):
		player.zoom_buffer_timer.start()
		tmp_zooming_pos = player.get_web_collision_pos()
	
	if player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling():
		if not player.zoom_buffer_timer.is_stopped():
			state_machine.transition_to("Zooming", {"position": tmp_zooming_pos})
			return
		else:
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
	
	# Draw line to zooming point
	player.draw_web(zooming_pos)

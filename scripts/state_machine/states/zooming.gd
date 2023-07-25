extends PlayerState

var zooming_pos : Vector2
var hook : Area2D

func _enter(msg := {}) -> void:
	player.set_current_down("b")
	
	zooming_pos = msg.get("position")
	
	# Disable gravity
	player.toggle_gravity()
	
	# Disable colliders
	player.disable_colliders()


func _exit() -> void:
	# Enable gravity
	player.toggle_gravity()


func _physics_update(delta: float) -> void:
	player.velocity += player.position.direction_to(zooming_pos) * player.get_zooming_speed() * delta
	
	if player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling():
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

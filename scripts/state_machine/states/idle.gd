extends PlayerState


func _update(delta : float) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jumping")
	
	var direction = Input.get_axis("left", "right")
	if direction:
		state_machine.transition_to("Walking")

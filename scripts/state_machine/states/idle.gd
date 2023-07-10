extends PlayerState


func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
	
	var direction = Input.get_axis("left", "right")
	if direction:
		state_machine.transition_to("Walking")

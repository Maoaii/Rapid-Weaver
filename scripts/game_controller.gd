extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_ddelta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

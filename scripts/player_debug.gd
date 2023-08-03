extends Control

@export var enable_state_debug: bool = true

@onready var state_label: Label = $CurrentState


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enable_state_debug:
		state_label.text = str(get_parent().get_node("StateMachine").state.name)

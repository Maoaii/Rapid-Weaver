extends Control

## Enable/Disable a Label above the player that shows in which state 
## the state machine currently is on
@export var enable_state_debug: bool = true

## Enable/Disable a drawn circle, starting from the player out to the player's
## max web range
@export var enable_web_range: bool = true


@export var enable_velocity_debug: bool = true

@onready var state_label: Label = $CurrentState
@onready var velocity_label: Label = $CurrentVelocity

func _ready() -> void:
	if enable_state_debug:
		state_label.show()
	else:
		state_label.hide()

func _process(_delta: float) -> void:
	if enable_state_debug:
		state_label.text = str(get_parent().get_node("StateMachine").state.name)
	
	if enable_velocity_debug:
		velocity_label.text = str(get_tree().get_first_node_in_group("Player").velocity)

class_name PlayerState
extends State

# Typed reference to the player node.
var player : Player


func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	player = owner as Player
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(player != null)

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot_web") and not player.zooming and player.web_is_colliding():
		# Transition to new state
		state_machine.transition_to("Zooming", {"position": player.get_web_collision_pos()})

class_name PlayerState
extends State

## Typed reference to the player node.
var player : Player
var zoom_collider: Node2D
var target_position: Vector2

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

func zoom() -> void:
	state_machine.transition_to("Zooming", 
				{"position": target_position,
				 "collider": zoom_collider})

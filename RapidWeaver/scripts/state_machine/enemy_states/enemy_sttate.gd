class_name EnemyState
extends State


## Typed reference to the enemy node.
var enemy : Enemy

func _ready() -> void:
	await owner.ready
	enemy = owner as Enemy
	assert(enemy != null)

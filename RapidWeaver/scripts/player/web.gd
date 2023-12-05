class_name Web
extends RayCast2D


var last_collider: Node2D
var last_target_position: Vector2
var hook: Hook

func _ready() -> void:
	EventBus._on_web_released.connect(remove_hook)

func set_hook(new_hook: Hook):
	if is_instance_valid(hook):
		hook.queue_free()
		hook = null
	hook = new_hook

func remove_hook() -> void:
	if is_instance_valid(hook):
		hook.remove_hook()
		hook = null

func set_last_collider():
	last_collider = get_collider()

func set_last_target_position():
	last_target_position = get_collision_point()

func get_last_collider():
	return last_collider

func get_last_target_position():
	return last_target_position

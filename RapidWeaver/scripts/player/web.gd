class_name Web
extends RayCast2D

@onready var web_hit_vfx: CPUParticles2D = $"../WebHit"

var last_collider: Node2D
var last_target_position: Vector2
var hook: Hook

func _ready() -> void:
	EventBus._on_web_released.connect(remove_hook)

func emit_web_vfx(_collided_objects, position_collided: Vector2) -> void:
	web_hit_vfx.global_position = position_collided
	web_hit_vfx.restart()

func set_hook(new_hook: Hook) -> void:
	if is_instance_valid(hook):
		hook.queue_free()
		hook = null
	hook = new_hook
	hook._on_destination_reached.connect(emit_web_vfx)

func remove_hook() -> void:
	if is_instance_valid(hook):
		hook.remove_hook()
		hook = null

func set_last_collider() -> void:
	last_collider = get_collider()

func set_last_target_position() -> void:
	last_target_position = get_collision_point()

func get_last_collider() -> Node2D:
	return last_collider

func get_last_target_position() -> Vector2:
	return last_target_position

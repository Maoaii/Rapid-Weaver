class_name Hook
extends Area2D

signal _on_destination_reached()

var target_pos: Vector2
var collider
var dir: Vector2
var speed: float = 100.0

func _physics_process(delta: float) -> void:
	if global_position.distance_to(target_pos) < 10:
		emit_signal("_on_destination_reached", "Zooming", {"position": target_pos, "collider": collider})
		queue_free()
		
	global_position += dir * speed * delta
	
	get_tree().get_first_node_in_group("Player").draw_web(global_position)

func set_target_pos(object_collided, pos: Vector2) -> void:
	collider = object_collided
	target_pos = pos
	dir = global_position.direction_to(pos).normalized()

func set_traveling_speed(new_speed: float) -> void:
	speed = new_speed

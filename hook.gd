class_name Hook
extends Area2D

signal _on_destination_reached()

var initial_position: Vector2
var max_range: float
var target_pos: Vector2
var dir: Vector2
var speed: float = 100.0
var player: Player
var active: bool = true

func _ready() -> void:
	initial_position = global_position
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	var collisions = get_overlapping_bodies()
	for collision in collisions:
		if collision.name == "Player":
			collisions.erase(collision)
	
	if len(collisions) > 0 :
		emit_signal("_on_destination_reached", collisions, global_position)
		queue_free()
		return
	
	if initial_position.distance_to(global_position) >= max_range:
		remove_hook()
		return
	
	global_position += dir * speed * delta
	
	if active:
		player.draw_web(global_position)

func remove_hook():
	player.remove_web()
	queue_free()
	active = false

func set_max_range(new_max_range: float) -> void:
	max_range = new_max_range

func set_target_pos(pos: Vector2) -> void:
	target_pos = pos
	dir = global_position.direction_to(pos).normalized()

func set_traveling_speed(new_speed: float) -> void:
	speed = new_speed

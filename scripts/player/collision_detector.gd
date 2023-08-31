class_name CollisionDetector
extends Node2D

@export_group("Collider lengths")
@export var up_collider_target: Vector2 = Vector2(0, -7)
@export var right_collider_target: Vector2 = Vector2(10, 0)
@export var down_collider_target: Vector2 = Vector2(0, 7)
@export var left_collider_target: Vector2 = Vector2(-10, 0)


@onready var up_collider: RayCast2D = $UpCollider
@onready var right_collider: RayCast2D = $RightCollider
@onready var down_collider: RayCast2D = $DownCollider
@onready var left_collider: RayCast2D = $LeftCollider


func _ready() -> void:
	up_collider.target_position = up_collider_target
	right_collider.target_position = right_collider_target
	down_collider.target_position = down_collider_target
	left_collider.target_position = left_collider_target


func enable_colliders() -> void:
	up_collider.enabled = true
	right_collider.enabled = true
	down_collider.enabled = true
	left_collider.enabled = true


func disable_colliders() -> void:
	up_collider.enabled = false
	right_collider.enabled = false
	down_collider.enabled = false
	left_collider.enabled = false


func is_colliding_up() -> bool:
	var is_colliding: bool = up_collider.is_colliding()
	
	if not is_colliding:
		return false
	
	var is_colliding_tilemap: bool = (up_collider.get_collider().is_class("TileMap") or up_collider.get_collider().is_in_group("Obstacle"))
	return is_colliding and is_colliding_tilemap


func is_colliding_right() -> bool:
	var is_colliding: bool = right_collider.is_colliding()
	
	if not is_colliding:
		return false
	
	var is_colliding_tilemap: bool = right_collider.get_collider().is_class("TileMap") or right_collider.get_collider().is_in_group("Obstacle")
	return is_colliding and is_colliding_tilemap


func is_colliding_down() -> bool:
	var is_colliding: bool = down_collider.is_colliding()
	
	if not is_colliding:
		return false
	
	var is_colliding_tilemap: bool = down_collider.get_collider().is_class("TileMap") or down_collider.get_collider().is_in_group("Obstacle")
	return is_colliding and is_colliding_tilemap


func is_colliding_left() -> bool:
	var is_colliding: bool = left_collider.is_colliding()
	
	if not is_colliding:
		return false
	
	var is_colliding_tilemap: bool = left_collider.get_collider().is_class("TileMap") or left_collider.get_collider().is_in_group("Obstacle")
	return is_colliding and is_colliding_tilemap

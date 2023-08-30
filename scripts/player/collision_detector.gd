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
	return up_collider.is_colliding()


func is_colliding_right() -> bool:
	return right_collider.is_colliding()


func is_colliding_down() -> bool:
	return down_collider.is_colliding()


func is_colliding_left() -> bool:
	return left_collider.is_colliding()

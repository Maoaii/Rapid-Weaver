class_name Player
extends CharacterBody2D

# Movement variables
@export var max_speed : float
@export var move_acceleration : float
@export var move_deceleration : float

# Jumping variables
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var terminal_velocity : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer : Timer = $JumpBufferTimer

var was_on_floor : bool

func _physics_process(delta):
	# Add the gravity
	apply_gravity(delta)


func apply_gravity(delta): 
	velocity.y += get_gravity() * delta
	velocity.y = min(velocity.y, terminal_velocity)


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

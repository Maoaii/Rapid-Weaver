class_name Player
extends CharacterBody2D

"""
	Export variables
"""
# Movement variables
@export var max_speed : float
@export var move_acceleration : float
@export var move_deceleration : float

# Jumping variables
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

# Wall Jumping variables
@export var wall_jump_velocity : float

# Falling variables
@export var terminal_velocity : float

"""
	Onready variables
"""
# Jumping variables
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

# Timers
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer : Timer = $JumpBufferTimer

# Animations
@onready var animation_sprite : AnimatedSprite2D = $AnimatedSprite2D

# Camera
@onready var camera : Camera2D = $Camera


"""
	Normal instance variables
"""
# Small state variables
var was_on_floor : bool
var is_sticky : bool = false
@onready var current_up : Vector2 = Vector2.UP
var current_animation : String

# Colliders
var is_colliding_up : bool
var is_colliding_right : bool
var is_colliding_down : bool
var is_colliding_left : bool

# Movement Input
var x_direction : float
var y_direction : float

func _physics_process(delta):
	# Add the gravity
	if not is_sticky:
		apply_gravity(delta)
	
	# Update colliders
	is_colliding_up = $StickyUp.is_colliding()
	is_colliding_right = $StickyRight.is_colliding()
	is_colliding_down = $StickyDown.is_colliding()
	is_colliding_left = $StickyLeft.is_colliding()
	
	# Update Movement Input
	x_direction = Input.get_axis("left", "right")
	y_direction = Input.get_axis("up", "down")

	# Play animation
	animation_sprite.play(current_animation)



func apply_gravity(delta): 
	velocity.y += get_gravity() * delta
	velocity.y = min(velocity.y, terminal_velocity)


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func set_animation(animation_name):
	current_animation = animation_name
	
	match current_up:
		Vector2.UP:
			animation_sprite.rotation_degrees = 0
			animation_sprite.flip_h = false
			animation_sprite.flip_v = false
		Vector2.RIGHT:
			animation_sprite.rotation_degrees = 90
			animation_sprite.flip_h = true
			animation_sprite.flip_v = false
		Vector2.DOWN:
			animation_sprite.rotation_degrees = 0
			animation_sprite.flip_h = false
			animation_sprite.flip_v = true
		Vector2.LEFT:
			animation_sprite.rotation_degrees = -90
			animation_sprite.flip_h = false
			animation_sprite.flip_v = false

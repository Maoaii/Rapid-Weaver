class_name Player
extends CharacterBody2D

"""
	Dictionaries
"""
const ROTATION_CODES = {
	"t": PI,
	"r": -PI/2,
	"l": -PI/2,
	"b": 0,
}

const FLIP_CODES = {
	"r": false,
	"l": true,
}


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
var current_animation : String
var current_down : Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	# Update rotation
	update_rotation()
	
	# Play animation
	animation_sprite.play(current_animation)



func apply_gravity(delta: float) -> void:
	if current_down == Vector2.UP:
		velocity.y -= get_gravity() * delta
		velocity.y = max(velocity.y, -terminal_velocity)
	elif current_down == Vector2.RIGHT:
		velocity.x += get_gravity() * delta
		velocity.x = min(velocity.x, terminal_velocity)
	elif current_down == Vector2.DOWN:
		velocity.y += get_gravity() * delta
		velocity.y = min(velocity.y, terminal_velocity)
	else:
		velocity.x -= get_gravity() * delta
		velocity.x = max(velocity.x, -terminal_velocity)


func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func set_animation(animation_name: String) -> void:
	current_animation = animation_name
	
	"""
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
	"""


func flip_sprite(flip_code : String) -> void:
	var flip_orientation = FLIP_CODES.get(flip_code.to_lower())
	
	animation_sprite.flip_h = flip_orientation


func update_rotation():
	if current_down == Vector2.UP:
		self.set_rotation(-PI)
	elif current_down == Vector2.RIGHT:
		self.set_rotation(-PI/2)
	elif current_down == Vector2.DOWN:
		self.set_rotation(0)
	else:
		self.set_rotation(PI/2)


func set_current_down(new_down: Vector2) -> void:
	current_down = new_down

func is_x_stationary() -> bool:
	return velocity.x == 0

func is_y_stationary() -> bool:
	return velocity.y == 0

func is_colliding_up() -> bool:
	return $StickyUp.is_colliding()

func is_colliding_right() -> bool:
	return $StickyRight.is_colliding()

func is_colliding_down() -> bool:
	return $StickyDown.is_colliding()

func is_colliding_left() -> bool:
	return $StickyLeft.is_colliding()

func get_y_input() -> float:
	return Input.get_axis("up", "down")

func get_x_input() -> float:
	return Input.get_axis("left", "right")

func has_input_left_right() -> bool:
	return Input.get_axis("left", "right") != 0

func has_input_up_down() -> bool:
	return Input.get_axis("up", "down") != 0

func has_input_up() -> bool:
	return Input.get_axis("up", "down") == -1

func has_input_right() -> bool:
	return Input.get_axis("left", "right") == 1

func has_input_down() -> bool:
	return Input.get_axis("up", "down") == 1

func has_input_left() -> bool:
	return Input.get_axis("left", "right") == -1

func is_stuck_up() -> bool:
	return current_down == Vector2.UP


func is_stuck_right() -> bool:
	return current_down == Vector2.RIGHT


func is_stuck_down() -> bool:
	return current_down == Vector2.DOWN


func is_stuck_left() -> bool:
	return current_down == Vector2.LEFT

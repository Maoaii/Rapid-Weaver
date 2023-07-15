class_name Player
extends CharacterBody2D

"""
	Dictionaries
"""
const ROTATION_CODES = {
	"t": PI,
	"r": PI/2,
	"l": -PI/2,
	"b": 0,
}

const FLIP_CODES = {
	"r": false,
	"l": true,
}

const DIRECTIONS = {
	"t": Vector2.UP,
	"r": Vector2.RIGHT,
	"b": Vector2.DOWN,
	"l": Vector2.LEFT
}

const STICK_SURFACE_CODE = {
	"t": Vector2(0, -500),
	"r": Vector2(500, 0),
	"b": Vector2(0, 500),
	"l": Vector2(-500, 0)
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
	#update_rotation()
	
	# Play animation
	animation_sprite.play(current_animation)


func apply_gravity(delta: float) -> void:
	var gravity : Vector2
	if self.is_stuck_up():
		gravity = Vector2(0, -self.get_gravity())
	elif self.is_stuck_right():
		gravity = Vector2(self.get_gravity(), 0)
	elif self.is_stuck_down():
		gravity = Vector2(0, self.get_gravity())
	else:
		gravity = Vector2(-self.get_gravity(), 0)
	
	velocity += gravity * delta


func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func set_animation(animation_name: String) -> void:
	current_animation = animation_name
	


func flip_sprite(flip_code : String) -> void:
	var flip_orientation = FLIP_CODES.get(flip_code.to_lower())
	
	animation_sprite.flip_h = flip_orientation


func update_rotation(new_rotation) -> void:
	if new_rotation == "t":
		self.set_rotation_degrees(180)
	elif new_rotation == "r":
		self.set_rotation_degrees(-90)
	elif new_rotation == "b":
		self.set_rotation_degrees(0)
	else:
		self.set_rotation_degrees(90)


func set_current_down(new_down: String) -> void:
	current_down = DIRECTIONS.get(new_down.to_lower())
	
	update_rotation(new_down)

func stick_to_surface(surface: String) -> void:
	velocity = STICK_SURFACE_CODE.get(surface.to_lower())

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
	return Input.is_action_pressed("up")

func has_input_right() -> bool:
	return Input.is_action_pressed("right")

func has_input_down() -> bool:
	return Input.is_action_pressed("down")

func has_input_left() -> bool:
	return Input.is_action_pressed("left")

func is_stuck_up() -> bool:
	return current_down == Vector2.UP


func is_stuck_right() -> bool:
	return current_down == Vector2.RIGHT


func is_stuck_down() -> bool:
	return current_down == Vector2.DOWN


func is_stuck_left() -> bool:
	return current_down == Vector2.LEFT

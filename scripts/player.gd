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

func _physics_process(delta):
	# Add the gravity
	apply_gravity(delta)
	
	# Handle Jump.
	handle_jump()
	
	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("left", "right")
	move(direction, delta)
	
	# Cap velocity
	cap_velocity()
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	handle_coyote_time(was_on_floor)


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		# Coyote time
		if is_on_floor() or !coyote_timer.is_stopped():
			velocity.y = jump_velocity
		elif !is_on_floor():
			jump_buffer_timer.start()
	
	# Jump buffer
	if is_on_floor() and !jump_buffer_timer.is_stopped():
		velocity.y = jump_velocity
	
	# Variable jump height
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.5


func apply_gravity(delta): 
	velocity.y += get_gravity() * delta
	velocity.y = min(velocity.y, terminal_velocity)


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func move(direction, delta):
	# Accelerate
	if direction:
		velocity.x += direction * move_acceleration * max_speed * delta
	# Decelerate
	elif velocity.x < 0:
		velocity.x += move_deceleration * max_speed * delta
		velocity.x = min(velocity.x, 0)
	elif velocity.x > 0:
		velocity.x -= move_deceleration * max_speed * delta
		velocity.x = max(velocity.x, 0)


func cap_velocity():
	if velocity.x > max_speed:
		velocity.x = max_speed
	elif velocity.x < -max_speed:
		velocity.x = -max_speed


func handle_coyote_time(was_on_floor):
	if was_on_floor and !is_on_floor():
		coyote_timer.start()

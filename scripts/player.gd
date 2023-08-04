class_name Player
extends CharacterBody2D

## Player Rotation codes
## Matches a string (that resembles a direction) to a rotation in radians
const ROTATION_CODES = {
	Global.DIRECTIONS.UP: PI, ## Top rotation
	Global.DIRECTIONS.RIGHT: PI/2, ## Right rotation
	Global.DIRECTIONS.DOWN: 0, ## Bottom rotation
	Global.DIRECTIONS.LEFT: -PI/2, ## Left rotation
}

## Sprite flip codes
## Matches a string (that resembles a direction) to the sprite flip I intend
const FLIP_CODES = {
	Global.DIRECTIONS.RIGHT: false, ## When going right, don't flip sprite
	Global.DIRECTIONS.LEFT: true, ## When going left, flip sprite
}


## Directions codes
## Matches string (that resembles a direction) to vectors
const DIRECTIONS = {
	Global.DIRECTIONS.UP: Vector2.UP,
	Global.DIRECTIONS.RIGHT: Vector2.RIGHT,
	Global.DIRECTIONS.DOWN: Vector2.DOWN,
	Global.DIRECTIONS.LEFT: Vector2.LEFT
}

## Surface stick codes
## Matches string (that resembles a direction) to vectors
const STICK_SURFACE_CODE = {
	Global.DIRECTIONS.UP: Vector2(0, -500),
	Global.DIRECTIONS.RIGHT: Vector2(500, 0),
	Global.DIRECTIONS.DOWN: Vector2(0, 500),
	Global.DIRECTIONS.LEFT: Vector2(-500, 0)
}



"""
	Export variables
"""
## Movement export variables
@export_group("Movement Variables")
@export var max_speed : float            ## Max speed the player can move at
@export var move_acceleration : float    ## The acceleration at which the player starts moving
@export var move_deceleration : float    ## The friction that's applied when the player stops moving

## Jumping export variables
@export_group("Jumping Variables")
@export var jump_height : float          ## Max jump height for the player
@export var jump_time_to_peak : float    ## Amount of time, in seconds, the player takes to reach the peak of their jump
@export var jump_time_to_descent : float ## Amount of time, in seconds, the player takes to reach the ground after jumping
@export var wall_jump_velocity : float   ## Velocity to jump from a wall

## Falling export variables
@export_group("Falling Variables")
@export var terminal_velocity : float    ## Terminal velocity for falling

## Web export variables
@export_group("Web Variables")
@export var simple_zooming: bool         ## Enable/Disable player simple zooming. Cancels the player velocity when transitioning to zooming
@export var web_range : float            ## Max web range for zooming
@export var zooming_max_speed: float     ## Max speed when zooming
@export var zooming_acceleration: float  ## The acceleration at which the player zooms



"""
	Onready variables
"""
## Jumping onready variables
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

## Onready Timers
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer : Timer = $JumpBufferTimer
@onready var zoom_buffer_timer : Timer = $ZoomBufferTimer

## Onreedy Animation player
@onready var animation_sprite : AnimatedSprite2D = $AnimatedSprite2D

## Onready Web raycast
@onready
var web : RayCast2D = $Web



"""
	Normal instance variables
"""
## Boolean that tells if the player was on the floor on the last frame
var was_on_floor : bool
## Variable to store the current animation
var current_animation : String
## Variable to keep track of the current down vector (to set gravity to)
var current_down : Vector2 = Vector2.DOWN
## Variable to know if gravity is currently turned on
var gravity_on : bool = true
## Variable to know if player is zooming
var zooming : bool = false


func _physics_process(delta: float) -> void:
	# Apply gravity to the player
	apply_gravity(delta)
	
	# Move the player
	move_and_slide()
	
	# Play animation
	animation_sprite.play(current_animation)
	
	# Update web aim
	web.target_position = web.position.direction_to(get_local_mouse_position()) * web_range
	queue_redraw()



"""
	Gravity functions
"""
## Function to apply gravity to the player
func apply_gravity(delta: float) -> void:
	if not gravity_on:
		return
	
	var gravity : Vector2
	if is_stuck_up():
		gravity = Vector2(0, -get_gravity())
	elif is_stuck_right():
		gravity = Vector2(get_gravity(), 0)
	elif is_stuck_down():
		gravity = Vector2(0, get_gravity())
	else:
		gravity = Vector2(-get_gravity(), 0)
	
	velocity += gravity * delta


func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func toggle_gravity() -> void:
	gravity_on = not gravity_on



"""
	Movement functions
"""
## Function to handle player movement along the x-axis
func move_x(delta: float) -> void:
	# Accelerate
	if has_input_left_right():
		velocity.x += get_x_input() * move_acceleration * max_speed * delta
	# Decelerate
	elif velocity.x < 0:
		velocity.x += move_deceleration * max_speed * delta
		velocity.x = min(velocity.x, 0)
	elif velocity.x > 0:
		velocity.x -= move_deceleration * max_speed * delta
		velocity.x = max(velocity.x, 0)
	
	was_on_floor = is_on_floor()
	
	cap_velocity_x(max_speed)

## Function to cap player velocity along the x-axis
func cap_velocity_x(max_velocity: float) -> void:
	velocity.x = clampf(velocity.x, -max_velocity, max_velocity)

## Function to handle player movement along the y-axis
func move_y(delta: float) -> void:
	# Accelerate
	if has_input_up_down():
		velocity.y += get_y_input() * move_acceleration * max_speed * delta
	# Decelerate
	elif velocity.y < 0:
		velocity.y += move_deceleration * max_speed * delta
		velocity.y = min(velocity.y, 0)
	elif velocity.y > 0:
		velocity.y -= move_deceleration * max_speed * delta
		velocity.y = max(velocity.y, 0)
	
	cap_velocity_y(max_speed)

## Function to cap player velocity along the y-axis
func cap_velocity_y(max_velocity: float) -> void:
	velocity.y = clampf(velocity.y, -max_velocity, max_velocity)


## Function to handle player jumping
func handle_jump(direction: Global.DIRECTIONS) -> void:
	if is_on_floor() or not coyote_timer.is_stopped():
		velocity.y = jump_velocity
	elif is_on_wall():
		if direction == Global.DIRECTIONS.RIGHT:
			# Jump right
			velocity = Vector2(wall_jump_velocity, -wall_jump_velocity)
		if direction == Global.DIRECTIONS.LEFT:
			# Jump left
			velocity = Vector2(-wall_jump_velocity, -wall_jump_velocity)
	else:
		jump_buffer_timer.start()
	
	# Jump buffer
	if is_on_floor() and not jump_buffer_timer.is_stopped():
		velocity.y = jump_velocity
	
	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5


func reset_velocity() -> void:
	velocity = Vector2.ZERO


func is_x_stationary() -> bool:
	return velocity.x == 0


func is_y_stationary() -> bool:
	return velocity.y == 0



"""
	Web functions
"""
var draw_list: Array = []
## Draws a web from player position to zooming point
func draw_web(zooming_pos: Vector2) -> void:
	draw_list.clear()
	draw_list.append([to_local(global_position), to_local(zooming_pos)])


func _draw() -> void:
	if draw_list.size() != 0:
		draw_dashed_line(draw_list[0][0], draw_list[0][1], Color.WHITE, 2, 2)
	
	if $PlayerDebug.enable_web_range:
		draw_arc(to_local(global_position), web_range, 0, 2*PI, 100, Color.WHITE)


## Clears the web drawing
func remove_web() -> void:
	draw_list.clear()


func web_is_colliding() -> bool:
	return web.is_colliding()


func get_web_collision_pos() -> Vector2:
	return web.get_collision_point()


func get_zooming_max_speed() -> float:
	return zooming_max_speed


func get_zooming_acceleration() -> float:
	return zooming_acceleration


func is_simple_zooming() -> bool:
	return simple_zooming



"""
	Colliders functions
"""
## Enables all directional colliders
func enable_colliders() -> void:
	$StickyUp.enabled = true
	$StickyRight.enabled = true
	$StickyDown.enabled = true
	$StickyLeft.enabled = true


## Disables all directional colliders
func disable_colliders() -> void:
	$StickyUp.enabled = false
	$StickyRight.enabled = false
	$StickyDown.enabled = false
	$StickyLeft.enabled = false


func is_colliding_up() -> bool:
	return $StickyUp.is_colliding()


func is_colliding_right() -> bool:
	return $StickyRight.is_colliding()


func is_colliding_down() -> bool:
	return $StickyDown.is_colliding()


func is_colliding_left() -> bool:
	return $StickyLeft.is_colliding()


## Checks if gravity is going up
func is_stuck_up() -> bool:
	return current_down == Vector2.UP


## Checks if gravity is going right
func is_stuck_right() -> bool:
	return current_down == Vector2.RIGHT


## Checks if gravity is going down
func is_stuck_down() -> bool:
	return current_down == Vector2.DOWN


## Checks if gravity is going left
func is_stuck_left() -> bool:
	return current_down == Vector2.LEFT



"""
	Sprite and Player Manipulation functions
"""
func reset_sprite_rotation() -> void:
	animation_sprite.rotation = 0


func reset_horizontal_flip() -> void:
	animation_sprite.flip_h = false


## Make sprite rotate towards a position
func sprite_look_at(pos: Vector2) -> void:
	animation_sprite.look_at(pos)


func set_animation(animation_name: String) -> void:
	current_animation = animation_name


## Flips the sprite when player on the ceiling
func flip_sprite_ceiling() -> void:
	if has_input_right():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif has_input_left():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)


## Flips the sprite when player on the ground
func flip_sprite_air_ground() -> void:
	if has_input_left():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif has_input_right():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)


## Flips the sprite when player on the walls
func flip_sprite_wall() -> void:
	if is_stuck_right():
		if has_input_up():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)
		elif has_input_down():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif is_stuck_left():
		if has_input_up():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
		elif has_input_down():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)


## Sets a new rotation for the player
func update_rotation(new_rotation: Global.DIRECTIONS) -> void:
	if new_rotation == Global.DIRECTIONS.UP:
		set_rotation_degrees(180)
	elif new_rotation == Global.DIRECTIONS.RIGHT:
		set_rotation_degrees(-90)
	elif new_rotation == Global.DIRECTIONS.DOWN:
		set_rotation_degrees(0)
	else:
		set_rotation_degrees(90)


## Sets a new down vector for the gravity to work in
func set_current_down(new_down: Global.DIRECTIONS) -> void:
	current_down = DIRECTIONS.get(new_down)
	
	update_rotation(new_down)


## Sticks the player to a given surface
func stick_to_surface(surface: Global.DIRECTIONS) -> void:
	velocity = STICK_SURFACE_CODE.get(surface)



"""
	Input functions
"""

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

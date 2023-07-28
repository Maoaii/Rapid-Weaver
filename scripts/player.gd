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
@export var max_speed : float
@export var move_acceleration : float
@export var move_deceleration : float

## Jumping export variables
@export_group("Jumping Variables")
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var wall_jump_velocity : float

## Falling export variables
@export_group("Falling Variables")
@export var terminal_velocity : float

## Web export variables
@export_group("Web Variables")
@export var simple_zooming: bool
@export var web_range : float
@export var zooming_max_speed: float
@export var zooming_acceleration: float

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

func toggle_gravity() -> void:
	gravity_on = not gravity_on

func enable_colliders() -> void:
	$StickyUp.enabled = true
	$StickyRight.enabled = true
	$StickyDown.enabled = true
	$StickyLeft.enabled = true

func disable_colliders() -> void:
	$StickyUp.enabled = false
	$StickyRight.enabled = false
	$StickyDown.enabled = false
	$StickyLeft.enabled = false

func reset_sprite_rotation() -> void:
	animation_sprite.rotation = 0

func remove_web() -> void:
	draw_list.clear()

func reset_horizontal_flip() -> void:
	animation_sprite.flip_h = false

func reset_velocity() -> void:
	velocity = Vector2.ZERO

func sprite_look_at(zooming_pos: Vector2) -> void:
	animation_sprite.look_at(zooming_pos)

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

var draw_list: Array = []
func draw_web(zooming_pos: Vector2) -> void:
	draw_list.clear()
	draw_list.append([to_local(self.global_position), to_local(zooming_pos)])

func _draw() -> void:
	if draw_list.size() != 0:
		draw_dashed_line(draw_list[0][0], draw_list[0][1], Color.WHITE, 2, 2)
	
	draw_arc(to_local(self.global_position), web_range, 0, 2*PI, 100, Color.WHITE)

func shoot_web(_delta) -> void:
	if web.is_colliding():
		var collision_point = web.get_collision_point()
		self.position = collision_point - Vector2(8, 8)

func move_x(delta):
	# Accelerate
	if self.has_input_left_right():
		self.velocity.x += self.get_x_input() * self.move_acceleration * self.max_speed * delta
	# Decelerate
	elif self.velocity.x < 0:
		self.velocity.x += self.move_deceleration * self.max_speed * delta
		self.velocity.x = min(self.velocity.x, 0)
	elif self.velocity.x > 0:
		self.velocity.x -= self.move_deceleration * self.max_speed * delta
		self.velocity.x = max(self.velocity.x, 0)
	
	self.was_on_floor = self.is_on_floor()
	
	cap_velocity_x(max_speed)

func cap_velocity_x(max_velocity: float):
	self.velocity.x = clampf(self.velocity.x, -max_velocity, max_velocity)

func move_y(delta):
	# Accelerate
	if self.has_input_up_down():
		self.velocity.y += self.get_y_input() * self.move_acceleration * self.max_speed * delta
	# Decelerate
	elif self.velocity.y < 0:
		self.velocity.y += self.move_deceleration * self.max_speed * delta
		self.velocity.y = min(self.velocity.y, 0)
	elif self.velocity.y > 0:
		self.velocity.y -= self.move_deceleration * self.max_speed * delta
		self.velocity.y = max(self.velocity.y, 0)
	
	cap_velocity_y(max_speed)

func cap_velocity_y(max_velocity: float):
	self.velocity.y = clampf(self.velocity.y, -max_velocity, max_velocity)

func handle_jump(direction):
	if self.is_on_floor() or not self.coyote_timer.is_stopped():
		self.velocity.y = self.jump_velocity
	elif self.is_on_wall():
		if direction == Global.DIRECTIONS.RIGHT:
			# Jump right
			self.velocity = Vector2(self.wall_jump_velocity, -self.wall_jump_velocity)
		if direction == Global.DIRECTIONS.LEFT:
			# Jump left
			self.velocity = Vector2(-self.wall_jump_velocity, -self.wall_jump_velocity)
	else:
		self.jump_buffer_timer.start()
	
	# Jump buffer
	if self.is_on_floor() and not self.jump_buffer_timer.is_stopped():
		self.velocity.y = self.jump_velocity
	
	# Variable jump height
	if Input.is_action_just_released("jump") and self.velocity.y < 0.0:
		self.velocity.y *= 0.5

func apply_gravity(delta: float) -> void:
	if not gravity_on:
		return
	
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

func flip_sprite_ceiling():
	if self.has_input_right():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif self.has_input_left():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)

func flip_sprite_air_ground():
	if self.has_input_left():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif self.has_input_right():
		animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)

func flip_sprite_wall():
	if self.is_stuck_right():
		if self.has_input_up():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)
		elif self.has_input_down():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
	elif self.is_stuck_left():
		if self.has_input_up():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.LEFT)
		elif self.has_input_down():
			animation_sprite.flip_h = FLIP_CODES.get(Global.DIRECTIONS.RIGHT)


func update_rotation(new_rotation: Global.DIRECTIONS) -> void:
	if new_rotation == Global.DIRECTIONS.UP:
		self.set_rotation_degrees(180)
	elif new_rotation == Global.DIRECTIONS.RIGHT:
		self.set_rotation_degrees(-90)
	elif new_rotation == Global.DIRECTIONS.DOWN:
		self.set_rotation_degrees(0)
	else:
		self.set_rotation_degrees(90)


func set_current_down(new_down: Global.DIRECTIONS) -> void:
	current_down = DIRECTIONS.get(new_down)
	
	update_rotation(new_down)

func stick_to_surface(surface: Global.DIRECTIONS) -> void:
	velocity = STICK_SURFACE_CODE.get(surface)

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

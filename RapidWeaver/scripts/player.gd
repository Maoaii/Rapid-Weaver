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
@export var bounce_force: float
## Amount of time the player has, before touching a surface, to prep a new jump
@export_range(0, 1, 0.05) var jump_buffer_time: float
## Amount of time the player has, after leaving the ground, to prep a new jump
@export_range(0, 1, 0.05) var coyote_time: float

## Falling export variables
@export_group("Falling Variables")
@export var terminal_velocity : float    ## Terminal velocity for falling
## Sprite stretch scale when player is in the air. It's based on the y-axis velocity of the player
@export_range(1, 2, 0.01) var max_stretch_on_velocity: float

## Web export variables
@export_group("Web Variables")
@export var simple_zooming: bool         ## Enable/Disable player simple zooming. Cancels the player velocity when transitioning to zooming
@export var web_release: bool            ## Enable/Disable player web rfelease on mouse click release
@export var web_travel_time: bool        ## Enable/Disable player's web travel time
@export var web_range : float            ## Max web range for zooming
@export var zooming_max_speed: float     ## Max speed when zooming
@export var zooming_acceleration: float  ## The acceleration at which the player zooms
@export var web_travelling_speed: float  ## The speed at which the player's web will travel to the target location
## Amount of time the player has, before touching a surface, to prep a new web zooming
@export_range(0, 1, 0.05) var zoom_buffer_time: float

## Variables related to health variables
@export_group("Health Variables")
@export var max_health: int = 3
@export var invincibility_time: float = 2
@export var knockback_force: Vector2 = Vector2(400, 250)
@export var death_force: Vector2

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
@onready var invincibility_timer: Timer = $InvincibilityTimer

## Onreedy Animation player
@onready var animation_sprite : AnimatedSprite2D = $AnimatedSprite2D

## Onready Web raycast
@onready
var web : Web = $Web

## Onready health component
@onready var health_component: HealthComponent = $HealthComponent

## Onready collision detector
@onready var collision_detector: CollisionDetector = $CollisionDetector

## Onready nudge detectors
@onready var left_nudge: RayCast2D = $NudgeColliders/LeftNudge
@onready var right_nudge: RayCast2D = $NudgeColliders/RightNudge

## Onready animation player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_animation: AnimationPlayer = $HitAnimation

## Onready jump audio stream player
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX
## Onready shoot audio stream player
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSFX
## Onready death audio stream player
@onready var death_sfx: AudioStreamPlayer2D = $DeathSFX

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
## Variable to know if the player is standing on a hurtable
var on_hurtable: bool = false
## Variable to know if the player is slowed
var slowed: bool = false

var dead: bool = false

var can_move: bool = true


@onready var sfx_nodes: Dictionary = {
	"jump": $JumpSFX,
	"shoot": $ShootSFX,
	"death": $DeathSFX,
	"hurt": $HurtSFX,
	"web_hit": $WebHitSFX
}

var last_pitch: float = 1.0
func play_sfx(sfx_name: String) -> void:
	if sfx_nodes.get(sfx_name) == null:
		return
	
	randomize()
	var pitch_scale: float = randf_range(0.8, 1.2)
	
	while abs(pitch_scale - last_pitch) < 0.1:
		randomize()
		pitch_scale = randf_range(0.8, 1.2)
	
	last_pitch = pitch_scale
	sfx_nodes.get(sfx_name).pitch_scale = pitch_scale
	sfx_nodes.get(sfx_name).play()

func _ready() -> void:
	# Assign timers to export variables
	coyote_timer.wait_time = coyote_time
	jump_buffer_timer.wait_time = jump_buffer_time
	zoom_buffer_timer.wait_time = zoom_buffer_time
	invincibility_timer.wait_time = invincibility_time
	
	# Assign health
	health_component.set_max_health(max_health)
	
	EventBus._on_web_released.connect(remove_web)
	EventBus._on_player_hurt.connect(hurt)
	EventBus._on_fungus_contact.connect(slow)
	EventBus._on_knockback_player.connect(knockback)
	EventBus._on_player_bounce.connect(bounce)
	EventBus._on_popup_show.connect(func(): can_move = false)
	EventBus._on_popup_hide.connect(func(): can_move = true)
	EventBus._on_death_area_touched.connect(death_area_touched)

func _process(_delta: float) -> void:
	if on_hurtable:
		EventBus._on_player_hurt.emit()

func set_jump_properties() -> void:
	jump_velocity = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
	jump_gravity = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
	fall_gravity = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	
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
	
	cap_velocity_y(terminal_velocity)


func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func toggle_gravity() -> void:
	gravity_on = not gravity_on

func apply_momentum(momentum: Vector2) -> void:
	velocity.x = momentum.x



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
	# Jump buffer
	if direction == Global.DIRECTIONS.UP or not coyote_timer.is_stopped():
		if not is_on_floor():
			return
		
		velocity.y = jump_velocity
	elif direction == Global.DIRECTIONS.LEFT or direction == Global.DIRECTIONS.RIGHT:
		if direction == Global.DIRECTIONS.RIGHT:
			# Jump right
			velocity = Vector2(wall_jump_velocity, -wall_jump_velocity/2)
		if direction == Global.DIRECTIONS.LEFT:
			# Jump left
			velocity = Vector2(-wall_jump_velocity, -wall_jump_velocity/2)
	else:
		jump_buffer_timer.start()

func bounce() -> void:
	velocity.y = -bounce_force

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
	Health functions
"""
func get_health() -> int:
	return health_component.health

func death_area_touched() -> void:
	health_component.take_damage(100)
	
	if health_component.health <= 0:
		dead = true

func hurt() -> void:
	if not invincibility_timer.is_stopped():
		return
	
	health_component.take_damage(1)
	EventBus._on_player_damage_taken.emit()
	if health_component.health <= 0:
		dead = true
	
	# Activate invincibility
	invincibility_timer.start()
	
	# Active flash animation
	hit_animation.play("hit")
	
	play_sfx("hurt")

func death_animation() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Collider.set_deferred("monitoring", false)
	velocity = Vector2(randf_range(-death_force.x, death_force.x), -death_force.y) 
	
	EventBus._unfollow_camera.emit()
	
	await get_tree().create_timer(1).timeout
	
	EventBus._on_player_death.emit()

func slow(speed_slow: float, zoom_slow: float, web_travel_slow: float, jump_height_slow: float, duration: float) -> void:
	if not slowed:
		# Apply debuffs
		# max_speed, web_zoom_speed, web_travel_time
		slowed = true
		max_speed -= speed_slow
		zooming_max_speed -= zoom_slow
		web_travelling_speed -= web_travel_slow
		jump_height -= jump_height_slow
		set_jump_properties()
		
		# Set timer
		var timer = get_tree().create_timer(duration)
		
		await timer.timeout
		
		# Redo debuffs
		slowed = false
		max_speed += speed_slow
		zooming_max_speed += zoom_slow
		web_travelling_speed += web_travel_slow
		jump_height += jump_height_slow
		set_jump_properties()


func knockback(knockback_origin: Vector2) -> void:
	if not invincibility_timer.is_stopped():
		return
	
	var dir: Vector2 = knockback_origin.direction_to(global_position).normalized()
	
	if dir.x > 0:
		dir = Vector2.RIGHT + Vector2.UP
	elif dir.x < 0:
		dir = Vector2.LEFT + Vector2.UP
	
	velocity = dir * knockback_force

"""
	Colliders functions
"""
func right_nudge_colliding() -> bool:
	return right_nudge.is_colliding()

func left_nudge_colliding() -> bool:
	return left_nudge.is_colliding()

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
func play_squash_animation() -> void:
	animation_player.play("squash")


func stretch_based_on_velocity() -> void:
	animation_sprite.scale.y = remap(abs(velocity.y), 0, max_speed, 1, max_stretch_on_velocity)
	animation_sprite.scale.x = 1 / animation_sprite.scale.y


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
	
	up_direction = current_down* Vector2(-1, -1)
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


"""
	Signals
"""
func _on_collider_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == "Decorations":
		var layer_name: String = body.get_layer_name(body.get_layer_for_body_rid(body_rid))
		
		if layer_name == "Hurtables":
			on_hurtable = true

func _on_collider_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == "Decorations":
		var layer_name: String = body.get_layer_name(body.get_layer_for_body_rid(body_rid))
		
		if layer_name == "Hurtables":
			on_hurtable = false

func emit_web_sfx(_a, _b) -> void:
	play_sfx("web_hit")

func shoot_web() -> Hook:
	var hook: Hook = load("res://hook.tscn").instantiate()
	hook.global_position = global_position
	get_tree().root.get_node("World").add_child(hook)
	
	hook.set_target_pos(get_global_mouse_position())
	hook.set_max_range(web_range)
	hook.set_traveling_speed(web_travelling_speed)
	
	hook.set_collision_mask_value(4, true)
	hook._on_destination_reached.connect(emit_web_sfx)
	
	if can_move:
		play_sfx("shoot")
	return hook

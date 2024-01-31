extends Node2D


@export_group("Camera Variables")
@export var camera: Camera2D
@export var enable_following_camera: bool = false
@export var camera_speed: float = 50

@export_group("Death Area Variables")
@export var death_area: DeathArea
@export var death_warning: DeathWarning

@export_group("Section Variables")
@export var sections: Array[PackedScene]

@onready var ui = preload("res://scenes/ui.tscn")

@onready var section_line = preload("res://scenes/section_line.tscn")

var spawned_sections: Array[BaseSection]
var player: Player
var moving_camera: bool = true
var game_started: bool = false

func _ready() -> void:
	await get_parent().ready
	create_new_section()
	
	player = get_tree().get_first_node_in_group("Player")
	
	EventBus._spawn_new_section.connect(add_new_section)
	EventBus._on_death_area_touched.connect(restart_game)
	EventBus._on_player_death.connect(restart_game)
	EventBus._unfollow_camera.connect(func(): moving_camera = false)
	EventBus._on_game_started.connect(start_game)
	
	await Soundmanager.ready
	Soundmanager.play_music("menu")

func start_game() -> void:
	if not game_started:
		var ui_instace = ui.instantiate()
		get_tree().root.get_node("World").add_child(ui_instace)
		Soundmanager.play_music("gameplay", true)
	
	game_started = true

func _process(delta: float) -> void:
	if moving_camera:
		update_camera(delta)
		
		# Increase camera movement
		if game_started:
			camera_speed += delta*2
	
	if player.global_position.distance_to(death_area.global_position) <= 400 and game_started:
		death_warning.play_animation()
	else:
		death_warning.stop_animation()

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("quit"):
		SceneTransition.change_scene("res://scenes/menus/main_menu/main_menu.tscn")
	
	if Input.is_action_just_pressed("restart"):
		restart_game()


func restart_game() -> void:
	SceneTransition.change_scene("res://scenes/menus/death_menu/death_menu.tscn")
	EventBus._on_game_restart.emit()
	Soundmanager.muffle_music()


func update_camera(delta: float) -> void:
	if enable_following_camera:
		camera.position.y = player.position.y
	else:
		camera.position += Vector2(0, -camera_speed * delta)
	
	if game_started:
		death_area.position.y += -camera_speed * delta
		#death_area.position.x = player.position.x - (Global.SECTION_WIDTH / 2)


func add_new_section() -> void:
	create_new_section()


func create_new_section() -> BaseSection:
	if sections.size() == 0:
		return null
	
	var new_section: BaseSection = sections.pick_random().instantiate()
	new_section.set_name("BaseSection" + str(spawned_sections.size()))
	get_parent().get_node("Sections").add_child.call_deferred(new_section)
	if spawned_sections.size() == 0:
		new_section.position += Vector2(0, -360)
	else:
		new_section.position += Vector2(0, 120 - Global.WINDOW_HEIGHT * (spawned_sections.size() + 1))
	
	var new_section_line: SectionLine = section_line.instantiate()
	
	new_section_line.set_name("SectionLine" + str(spawned_sections.size()))
	new_section_line.position = Vector2(0, new_section.position.y + 60)
	new_section_line.set_label(abs(new_section_line.position.y) / 10)
	
	get_parent().get_node("Sections").add_child.call_deferred(new_section_line)
	spawned_sections.push_back(new_section)
	
	
	return new_section

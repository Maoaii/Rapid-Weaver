extends Node2D


@export_group("Camera Variables")
@export var camera: Camera2D
@export var enable_following_camera: bool = false
@export var camera_speed: int = 50

@export_group("Death Area Variables")
@export var death_area: DeathArea

@export_group("Section Variables")
@export var sections: Array[PackedScene]


var spawned_sections: Array[BaseSection]
var player: Player

func _ready() -> void:
	create_new_section()
	
	player = get_tree().get_first_node_in_group("Player")
	
	EventBus._on_section_passed.connect(add_new_section)
	EventBus._on_death_area_touched.connect(restart_game)
	EventBus._on_player_death.connect(restart_game)


func _process(delta: float) -> void:
	update_camera(delta)

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("quit"):
		SceneTransition.change_scene("res://scenes/menus/main_menu/main_menu.tscn")
	
	if Input.is_action_just_pressed("restart"):
		restart_game()


func restart_game() -> void:
	EventBus._on_game_restart.emit()
	SceneTransition.change_scene("res://scenes/menus/death_menu/death_menu.tscn")


func update_camera(delta: float) -> void:
	if enable_following_camera:
		camera.position.y = player.position.y
	else:
		camera.offset += Vector2(0, -camera_speed * delta)
		death_area.position += Vector2(0, -camera_speed * delta)
	
	death_area.position.x = player.position.x - (Global.SECTION_WIDTH / 2)


func add_new_section() -> void:
	create_new_section()


func create_new_section() -> BaseSection:
	var new_section: BaseSection = sections.pick_random().instantiate()
	new_section.set_name("BaseSection" + str(spawned_sections.size()))
	get_parent().get_node("Sections").add_child.call_deferred(new_section)
	new_section.position += Vector2(0, -Global.WINDOW_HEIGHT * (spawned_sections.size() + 1))
	spawned_sections.push_back(new_section)
	
	return new_section

extends Node2D


@export var camera: Camera2D
@export var enable_following_camera: bool = false
@export var sections: Array[PackedScene]
@export var camera_speed: int = 50

var spawned_sections: Array[BaseSection]

func _ready() -> void:
	create_new_section()


func _process(delta: float) -> void:
	update_camera(delta)
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("restart"):
		restart_game()


func restart_game() -> void:
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/world.tscn")



func update_camera(delta: float) -> void:
	if enable_following_camera:
		camera.position = get_tree().get_first_node_in_group("Player").position
	else:
		camera.offset += Vector2(0, -camera_speed * delta)


func add_new_section() -> void:
	create_new_section()
	
	Global.section_passed()


func create_new_section() -> BaseSection:
	var new_section: BaseSection = sections.pick_random().instantiate()
	new_section.set_name("BaseSection" + str(spawned_sections.size()))
	get_parent().get_node("Sections").add_child.call_deferred(new_section)
	new_section.position += Vector2(0, -Global.WINDOW_HEIGHT * spawned_sections.size())
	spawned_sections.push_back(new_section)
	
	new_section.on_top_reached.connect(add_new_section)
	
	return new_section

extends Node2D

@export var enable_following_camera: bool = false
@export var sections: Array[PackedScene]
@export var camera_speed: int = 50

@onready var camera: Camera2D = $Camera2D

var spawned_sections: Array[BaseSection]

func _ready() -> void:
	create_new_section()


func _process(delta: float) -> void:
	if enable_following_camera:
		camera.position = get_tree().get_first_node_in_group("Player").position
	else:
		camera.offset += Vector2(0, -camera_speed * delta)


func add_new_section() -> void:
	create_new_section()


func create_new_section() -> BaseSection:
	var new_section: BaseSection = sections.pick_random().instantiate()
	new_section.set_name("BaseSection" + str(spawned_sections.size()))
	$Sections.add_child.call_deferred(new_section)
	new_section.position += Vector2(0, -Global.WINDOW_HEIGHT * spawned_sections.size())
	spawned_sections.push_back(new_section)
	
	new_section.on_top_reached.connect(add_new_section)
	
	return new_section

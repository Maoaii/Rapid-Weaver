extends Node2D

@export var sections: Array[PackedScene]
@export var camera_speed: int = 50

@onready var camera: Camera2D = $Camera2D

var spawned_sections: Array[BaseSection]

func _ready() -> void:
	create_new_section()


func _process(delta: float) -> void:
	camera.offset += Vector2(0, -camera_speed * delta)


func add_new_section() -> void:
	create_new_section()


func create_new_section() -> BaseSection:
	var new_section: BaseSection = sections.pick_random().instantiate()
	new_section.set_name("BaseSection" + str(spawned_sections.size()))
	$Sections.add_child.call_deferred(new_section)
	new_section.position += Vector2(0, -480 * spawned_sections.size())
	spawned_sections.push_back(new_section)
	
	new_section.on_top_reached.connect(add_new_section)
	
	
	return new_section

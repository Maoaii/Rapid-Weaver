extends Node2D

@export var base_section: PackedScene

var sections: Array[BaseSection]

func _ready() -> void:
	create_new_section()


func add_new_section() -> void:
	create_new_section()


func create_new_section() -> BaseSection:
	var new_section: BaseSection = base_section.instantiate()
	new_section.set_name("BaseSection" + str(sections.size()))
	add_child.call_deferred(new_section)
	new_section.position += Vector2(0, -480 * sections.size())
	sections.push_back(new_section)
	
	new_section.on_top_reached.connect(add_new_section)
	
	
	return new_section

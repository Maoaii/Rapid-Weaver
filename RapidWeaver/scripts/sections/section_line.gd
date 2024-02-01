class_name SectionLine
extends Node2D

@export var can_score: bool = true

@onready var height_label: Label = $PanelContainer/MarginContainer/HeightLabel
var new_value: String = "0"

func _ready() -> void:
	height_label.text = new_value + " Meters"

func set_label(value: int) -> void:
	new_value = str(value)


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		$Area2D.queue_free()
		
		if can_score:
			EventBus._on_section_passed.emit()

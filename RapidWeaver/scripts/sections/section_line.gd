class_name SectionLine
extends Node2D

@onready var height_label: Label = $PanelContainer/MarginContainer/HeightLabel
var new_value: String = "0"

func _ready() -> void:
	height_label.text = new_value + " Meters"

func set_label(value: int) -> void:
	new_value = str(value)

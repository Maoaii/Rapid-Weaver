class_name BaseSection
extends Node2D


func _on_top_screen_notifier_screen_entered():
	EventBus._on_section_passed.emit()

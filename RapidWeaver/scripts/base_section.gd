class_name BaseSection
extends Node2D


func _on_top_screen_notifier_screen_entered():
	EventBus._spawn_new_section.emit()

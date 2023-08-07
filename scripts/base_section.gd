class_name BaseSection
extends Node2D

signal on_top_reached


func _on_top_screen_notifier_screen_entered():
	# Spawn a new section above this one
	emit_signal("on_top_reached")

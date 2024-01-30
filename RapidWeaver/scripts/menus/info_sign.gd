extends Area2D

@export var sign_hover_text: String
@export var sign_display_scene: PackedScene

@onready var sign_hover_label: Label = $FloatingArrow/DownArrow/SignText

var sign_display_instance: Node2D = null

func _ready() -> void:
	sign_hover_label.text = sign_hover_text
	
	if sign_display_scene == null:
		return
	
	sign_display_instance = sign_display_scene.instantiate()
	$Marker.add_child(sign_display_instance)
	sign_display_instance.modulate.a = 0


func _on_body_entered(_body) -> void:
	if sign_display_scene == null:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(sign_display_instance, "modulate:a", 1, 0.2)


func _on_body_exited(_body) -> void:
	if sign_display_scene == null:
		return
	
	var tween = get_tree().create_tween()
	tween.tween_property(sign_display_instance, "modulate:a", 0, 0.2)

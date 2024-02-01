extends Marker2D

@export var popup_scene: PackedScene

func _ready() -> void:
	randomize()
	EventBus._on_score_popup.connect(popup)

func popup(score: int) -> void:
	var popup_instance = popup_scene.instantiate()
	popup_instance.position = global_position
	popup_instance.set_label(str(score))
	
	var tween = get_tree().create_tween()
	tween.tween_property(popup_instance, "position", global_position + _get_direction(), 0.75)
	
	get_tree().current_scene.add_child(popup_instance)

func _get_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), -randf() * 16)

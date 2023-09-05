extends Area2D


func _ready() -> void:
	$AnimationPlayer.play("Float")


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		EventBus._on_fly_eaten.emit()
		queue_free()


func _on_area_entered(area):
	if area.name == "Hook":
		EventBus._on_fly_eaten.emit()
		queue_free()

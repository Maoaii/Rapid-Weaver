extends Area2D


func _ready() -> void:
	$AnimationPlayer.play("Float")


func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		Global.picked_up_fly()
		queue_free()

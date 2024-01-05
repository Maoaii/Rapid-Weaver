extends PlayerState

func _enter(msg := {}) -> void:
	player.death_animation()

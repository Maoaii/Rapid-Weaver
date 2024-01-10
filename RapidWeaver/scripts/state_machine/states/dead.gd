extends PlayerState

func _enter(_msg := {}) -> void:
	player.death_animation()
	player.play_sfx("death")

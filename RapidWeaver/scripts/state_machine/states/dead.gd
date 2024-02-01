extends PlayerState

func _enter(_msg := {}) -> void:
	player.set_current_down(Global.DIRECTIONS.DOWN)
	player.death_animation()
	player.play_sfx("death")

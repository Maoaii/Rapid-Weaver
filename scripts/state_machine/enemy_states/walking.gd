extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Walking")

extends EnemyState

func _enter(_msg := {}) -> void:
	enemy.play_animation("Idle")
	
	enemy.idle_timer.start(enemy.idle_length)
	
	await enemy.idle_timer.timeout
	idle_timer_ended()

func _exit() -> void:
	enemy.idle_timer.stop()

func _physics_update(_delta: float) -> void:
	enemy.x_dir = Vector2.ZERO

func idle_timer_ended() -> void:
	state_machine.transition_to("Walking")

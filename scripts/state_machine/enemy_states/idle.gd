extends EnemyState

var is_idle: bool = false

func _enter(_msg := {}) -> void:
	is_idle = true
	
	enemy.play_animation("Idle")
	
	enemy.idle_timer.start(enemy.idle_length)
	
	await enemy.idle_timer.timeout
	idle_timer_ended()

func _exit() -> void:
	is_idle = false
	enemy.idle_timer.stop()

func _physics_process(_delta: float) -> void:
	if is_idle:
		enemy.x_dir = Vector2.ZERO

func idle_timer_ended() -> void:
	state_machine.transition_to("Walking")

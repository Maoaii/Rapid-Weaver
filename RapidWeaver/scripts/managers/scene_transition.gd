extends CanvasLayer

@onready var dissolve_rect: ColorRect = $DissolveRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()

func change_scene(target: String, type: String = "dissolve") -> void:
	if type == "dissolve":
		show()
		await transition_dissolve(target)
		Soundmanager.setup_button_sounds()

func transition_dissolve(target: String) -> void:
	animation_player.play("dissolve")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(target)
	animation_player.play_backwards("dissolve")
	await animation_player.animation_finished
	hide()

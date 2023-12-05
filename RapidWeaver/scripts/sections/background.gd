extends ParallaxBackground

@export var speed: float = 10

func _process(delta: float) ->  void:
	scroll_offset.y += speed * delta

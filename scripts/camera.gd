extends Camera2D


func _ready() -> void:
	set_camera_limits()


func set_camera_limits() -> void:
	var tilemap_rect = get_parent().get_parent().get_node("TileMap").get_used_rect()
	var tilemap_cell_size = get_parent().get_parent().get_node("TileMap").cell_quadrant_size
	
	self.limit_top = tilemap_rect.position.y * tilemap_cell_size
	self.limit_bottom = tilemap_rect.end.y * tilemap_cell_size

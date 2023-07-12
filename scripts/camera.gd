extends Camera2D

# Camera settings variables
@export var dead_zone : float
@export var limit : Vector2


func _ready():
	set_camera_limits()
	


func _process(_delta):
	update_camera_pos()


func set_camera_limits():
	var tilemap_rect = get_parent().get_parent().get_node("TileMap").get_used_rect()
	var tilemap_cell_size = get_parent().get_parent().get_node("TileMap").cell_quadrant_size
	
	self.limit_top = tilemap_rect.position.y * tilemap_cell_size
	self.limit_right = tilemap_rect.end.x * tilemap_cell_size
	self.limit_bottom = tilemap_rect.end.y * tilemap_cell_size
	self.limit_left = tilemap_rect.position.x * tilemap_cell_size


func update_camera_pos():
	var mouse_pos = get_local_mouse_position()
	
	if mouse_pos.length() <= dead_zone:
		self.position = self.position.lerp(Vector2.ZERO, 0.1)
	else:
		self.position = self.position.lerp(mouse_pos.clamp(-limit, limit), 0.1)

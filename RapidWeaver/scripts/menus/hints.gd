extends Node2D

@onready var up: ColorRect = $WBG
@onready var down: ColorRect = $SBG
@onready var right: ColorRect = $DBG
@onready var left: ColorRect = $ABG
@onready var mouse: AnimatedSprite2D = $Mouse/mouse


func _unhandled_input(_event) -> void:
	if Input.is_action_pressed("up"):
		up.color.a = 0.5
	else:
		up.color.a = 0.15
	
	if Input.is_action_pressed("down"):
		down.color.a = 0.5
	else:
		down.color.a = 0.15
	
	if Input.is_action_pressed("right"):
		right.color.a = 0.5
	else:
		right.color.a = 0.15
	
	if Input.is_action_pressed("left"):
		left.color.a = 0.5
	else:
		left.color.a = 0.15
	
	if Input.is_action_pressed("shoot_web"):
		mouse.play("Clicked")
	else:
		mouse.play("None")

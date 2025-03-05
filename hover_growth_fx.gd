extends Node

@export_range(0.0, 2.0) var growth_strength = 1.2

@onready var parent = get_parent()
@onready var parent_valid = parent is Control

func _ready():
	if parent_valid:
		parent.mouse_entered.connect(func(): parent.scale *= 1.2)
		parent.mouse_exited.connect(func(): parent.scale = Vector2.ONE)

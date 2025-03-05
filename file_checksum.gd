class_name HotReloader
extends Node


@onready var last_file_checksum : String
@onready var hot_reload_timer = $HotReloadTimer

@onready var hot_reload_dialogue = $"../HotReloadDialogue"
var path : String = ""

func _ready():
	hot_reload_dialogue.visible = false
	
func start():
	last_file_checksum = FileAccess.get_md5(path)
	
	hot_reload_timer.timeout.connect(func(): 
		var current_file_checksum := FileAccess.get_md5(path)
		if current_file_checksum != last_file_checksum && last_file_checksum != "":
			hot_reload_dialogue.visible = true
			last_file_checksum = current_file_checksum
	)

	

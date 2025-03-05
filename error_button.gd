extends Button

func _ready():
	button_up.connect(get_tree().quit)

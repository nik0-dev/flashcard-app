extends Panel

@onready var no_button = $DialogueContents/NoButton
@onready var yes_button = $DialogueContents/YesButton

func _ready():
	no_button.button_up.connect(func(): hide())
	yes_button.button_up.connect(func(): get_tree().reload_current_scene())

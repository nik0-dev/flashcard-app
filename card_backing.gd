class_name Flashcard

extends Panel

var hovered : bool = false

@onready var flashcard_content = $FlashcardContent
@onready var animation_player = $AnimationPlayer

var animation_playing : bool = false

var front_text : String 
var back_text : String
@onready var state_text = $State as Label
 
enum State {
	FRONT = 0,
	BACK = 1
}

var state : State = State.FRONT

func _ready():
	mouse_entered.connect(func(): hovered = true)
	mouse_exited.connect(func(): hovered = false)
	set_contents()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT && hovered:
			if !animation_player.is_playing():
				flip()

func next():
	if !animation_player.is_playing():
		animation_player.play("next")
	
func last():
	if !animation_player.is_playing():
		animation_player.play("last")
	
func flip(): 
	@warning_ignore("int_as_enum_without_cast")
	state = 1 - state
	animation_player.play("flip")

func reset_state():
	state = State.FRONT
	set_contents()
	
func set_contents():
	match state:
		State.FRONT: 
			flashcard_content.text = front_text
			state_text.text = "Front"
		State.BACK: 
			flashcard_content.text = back_text
			state_text.text = "Back"

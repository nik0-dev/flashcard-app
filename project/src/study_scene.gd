extends Control

var dict : Dictionary[String, String]

@onready var error_dialogue = $ErrorDialogue
@onready var error_dialogue_msg = %Dialogue

@onready var next_button = $NextButton
@onready var last_button = $LastButton
@onready var flashcard = $Flashcard as Flashcard
@onready var flashcard_content = $Flashcard/FlashcardContent
@onready var hot_reloader = $HotReloader as HotReloader
@onready var count = $Flashcard/Count as Label
@onready var tts = $TTS
@onready var play_tts = $PlayTTS
@onready var open_list = $OpenList
@onready var shuffle = $Shuffle

var target_file_name : String = ""

var card_index = 0

var front_cards : Array[String] = []
var back_cards : Array[String] = []
var ordering : Array[int] = []

var next_button_hovered : bool = false
var last_button_hovered : bool = false

var tts_front_threads : Array[Thread] = []
var tts_back_threads  : Array[Thread] = []

func _ready():
	error_dialogue.hide()
	handle_signals()
	load_cards()

func _process(_delta):
	for thread in tts_front_threads:
		if !thread.is_alive():
			tts_front_threads.erase(thread)
			thread.wait_to_finish()
	for thread in tts_back_threads:
		if !thread.is_alive():
			tts_back_threads.erase(thread)
			thread.wait_to_finish()

	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if next_button_hovered && card_index != dict.size() - 1:
				card_index += 1
				flashcard.next()
			if last_button_hovered && card_index != 0:
				card_index -= 1
				flashcard.last()

func load_cards():
	var dir = DirAccess.open("")
	
	if dir == null: 
		error_dialogue_msg.text = "Couldn't open the executable directory."
		error_dialogue.show()
		return
		
	var files = dir.get_files()
	
	for file in files:
		if file.get_extension() == "cards":
			target_file_name = file
			hot_reloader.path = target_file_name
			hot_reloader.start()
			break
	
	if target_file_name == "":
		error_dialogue_msg.text = "Couldn't find a file with the '.cards' extension."
		error_dialogue.show()
		return
	
	var card_list = FileAccess.open(target_file_name, FileAccess.READ)
	
	if card_list == null:
		error_dialogue_msg.text = "Couldn't open the card list file."
		error_dialogue.show()
		return
		
	var card_list_contents = card_list.get_as_text()
	for card in card_list_contents.split("\n"):
		var filtered = card
		var pair : PackedStringArray = filtered.split(",")

		if pair.size() == 2:
			front_cards.append(filter_text(pair[0]))
			back_cards.append(filter_text(pair[1]))
			ordering.append(ordering.size())
	
	update_card()

func handle_signals():
	next_button.mouse_entered.connect(func(): next_button_hovered = true)
	next_button.mouse_exited.connect(func(): next_button_hovered = false)
	last_button.mouse_entered.connect(func(): last_button_hovered = true)
	last_button.mouse_exited.connect(func(): last_button_hovered = false)
	play_tts.button_up.connect(func():
		if tts_front_threads.size() == 0 && tts_back_threads.size() == 0:
			var file_name = "front.wav" if flashcard.state == Flashcard.State.FRONT else "back.wav"
			tts.play_tts_file(file_name)
	)
	open_list.button_up.connect(func():
		OS.shell_open(tts.working_dir + "../list.cards")
	)
	shuffle.button_up.connect(func():
		ordering.shuffle()
		update_card()
	)

func filter_text(text: String) -> String:
	var filtered = text
	filtered = filtered.strip_edges(true, true)
	filtered = filtered.replace("\t", "")
	filtered = filtered.replace("\r", "")
	return filtered

func update_card():
	if ordering.size() > 0:
		flashcard.front_text = front_cards[ordering[card_index]]
		flashcard.back_text = back_cards[ordering[card_index]]
		flashcard.reset_state()
		count.text = str(card_index + 1) + "/" + str(ordering.size()) 
		var front_thread := Thread.new()
		var back_thread := Thread.new()
		front_thread.start(tts.generate_tts_file.bind(flashcard.front_text, "pl_PL-darkman-medium", "front.wav"))
		tts_front_threads.push_back(front_thread)
		back_thread.start(tts.generate_tts_file.bind(flashcard.back_text, "en_US-amy-low", "back.wav"))
		tts_back_threads.push_back(back_thread)

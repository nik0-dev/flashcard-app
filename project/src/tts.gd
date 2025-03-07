class_name TTS
extends Node

@onready var audio_stream_player = $AudioStreamPlayer

## this is the path to the piper binary, assumes that is set up as an environment variable
@export var default_language_pack : String 


var working_dir : String
var piper_binary : String
var piper_language_pack : String

func _ready():
	if OS.has_feature("template"):
		working_dir = OS.get_executable_path().get_base_dir() + "/"
	else:
		working_dir = ProjectSettings.globalize_path("res://")
	working_dir += "piper/"
	piper_binary = working_dir + "piper.exe"
	print(working_dir)

func generate_tts_file(contents: String, language: String, file_name: String):
	var output = []
	piper_language_pack = working_dir + language
	var cmd : String =  "cd %s ; echo %s | %s -m %s.onnx -f %s" % [working_dir, contents, piper_binary, piper_language_pack, file_name]
	OS.execute("powershell.exe", ["-Command", cmd], output)
		
		
func play_tts_file(file_name: String):
	if !audio_stream_player.playing:
		var stream : AudioStreamWAV = AudioStreamWAV.load_from_file(working_dir + file_name)
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.stereo = false
		audio_stream_player.stream = stream
		audio_stream_player.play()

	
	

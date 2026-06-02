extends Node

var bg_music
var sfx_swap
var sfx_match

var music_enabled = true
var sfx_enabled = true

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	bg_music = AudioStreamPlayer.new()
	bg_music.stream = load("res://Assets/Audio/ambient.mp3")
	bg_music.volume_db = -5
	add_child(bg_music)
	
	bg_music.connect("finished", Callable(bg_music, "play"))
	bg_music.play()
	
	sfx_swap = AudioStreamPlayer.new()
	sfx_swap.stream = load("res://Assets/Audio/swap.wav")
	sfx_swap.volume_db = 2
	add_child(sfx_swap)
	
	sfx_match = AudioStreamPlayer.new()
	sfx_match.stream = load("res://Assets/Audio/match.wav")
	sfx_match.volume_db = 5
	add_child(sfx_match)

func play_swap():
	if sfx_enabled:
		sfx_swap.play()

func play_match():
	if sfx_enabled:
		sfx_match.play()

func set_music(enabled):
	music_enabled = enabled
	if music_enabled:
		if not bg_music.playing:
			bg_music.play()
	else:
		bg_music.stop()

func set_sfx(enabled):
	sfx_enabled = enabled

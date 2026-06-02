extends Control

func _ready():
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var video = VideoStreamPlayer.new()
	if ResourceLoader.exists("res://Assets/Videos/intro.ogv"):
		video.stream = load("res://Assets/Videos/intro.ogv")
		
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	video.expand = true
	add_child(video)
	
	if video.stream != null:
		video.connect("finished", Callable(self, "_on_video_finished"))
		video.play()
		
		var skip_btn = Button.new()
		skip_btn.text = "Geç >>"
		skip_btn.position = Vector2(400, 50)
		skip_btn.size = Vector2(100, 50)
		skip_btn.add_theme_font_size_override("font_size", 24)
		skip_btn.connect("pressed", Callable(self, "_on_video_finished"))
		add_child(skip_btn)
	else:
		# If no video is provided yet, show a fake intro text for 2 seconds
		var lbl = Label.new()
		lbl.text = "(Açılış Videosu Alanı)\nVideo 'Assets/Videos/intro.ogv' dizininde bulunamadı.\n\nGerçek video yüklenene kadar\nbu ekran simüle ediliyor..."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.set_anchors_preset(Control.PRESET_CENTER)
		add_child(lbl)
		
		var timer = get_tree().create_timer(3.0)
		timer.connect("timeout", Callable(self, "_on_video_finished"))

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

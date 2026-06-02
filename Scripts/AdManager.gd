extends Node

signal interstitial_closed

var app_id = "ca-app-pub-7470017453637950~1769028185"
var interstitial_id = "ca-app-pub-7470017453637950/1661520893"
var is_admob_ready = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var admob_node = get_node_or_null("/root/AdmobNode")
	if Engine.has_singleton("AdmobPlugin") and admob_node != null:
		# Configure Admob
		admob_node.is_real = true
		admob_node.android_real_interstitial_id = interstitial_id
		admob_node.ios_real_interstitial_id = interstitial_id # Usually you have a separate one for iOS
		
		# Connect to initialization
		admob_node.connect("initialization_completed", Callable(self, "_on_admob_initialized"))
		
		# Connect to interstitial events
		admob_node.connect("interstitial_ad_dismissed_full_screen_content", Callable(self, "_on_interstitial_dismissed"))
		admob_node.connect("interstitial_ad_failed_to_show_full_screen_content", Callable(self, "_on_interstitial_dismissed"))
		
		admob_node.initialize()
	else:
		print("AdManager: Admob native plugin not found (PC/Mac). Using simulation.")

func _on_admob_initialized(_status):
	print("AdManager: Admob initialized!")
	is_admob_ready = true
	# Automatically load the first one
	get_node("/root/AdmobNode").load_interstitial_ad()

func load_interstitial():
	if is_admob_ready:
		get_node("/root/AdmobNode").load_interstitial_ad()
	else:
		print("AdManager: Loading mock interstitial ad (ID: " + interstitial_id + ")")

func show_interstitial():
	if is_admob_ready:
		if get_node("/root/AdmobNode").is_interstitial_ad_loaded():
			get_node("/root/AdmobNode").show_interstitial_ad()
		else:
			print("AdManager: Ad not loaded yet. Trying to show mock or skipping.")
			_on_interstitial_dismissed(null) # fallback to close
	else:
		print("AdManager: Showing mock interstitial ad")
		_show_mock_ad()

func _on_interstitial_dismissed(_ad_info = null):
	emit_signal("interstitial_closed")
	# Preload next
	if is_admob_ready:
		get_node("/root/AdmobNode").load_interstitial_ad()

func _show_mock_ad():
	var canvas = CanvasLayer.new()
	canvas.layer = 120
	get_tree().root.add_child(canvas)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(bg)
	
	var lbl = Label.new()
	lbl.text = "TAM EKRAN REKLAM SİMÜLASYONU\n\nAd Unit ID:\n" + interstitial_id + "\n\n(Telefonda AdMob Plugin ile\nburada gerçek reklam çıkacak)"
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(0, 400)
	lbl.size = Vector2(540, 200)
	canvas.add_child(lbl)
	
	var close_btn = Button.new()
	close_btn.text = "X Kapat"
	close_btn.position = Vector2(380, 50)
	close_btn.size = Vector2(120, 60)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.connect("pressed", Callable(self, "_on_mock_close").bind(canvas))
	canvas.add_child(close_btn)

func _on_mock_close(canvas):
	canvas.queue_free()
	_on_interstitial_dismissed()

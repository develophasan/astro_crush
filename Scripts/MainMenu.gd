extends Control

func _ready():
	# Clean up any existing nodes from tscn
	for child in get_children():
		child.queue_free()
		
	# Background
	var bg = TextureRect.new()
	bg.texture = load("res://Assets/Images/bg.jpg")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_COVER
	bg.size = get_viewport_rect().size
	add_child(bg)
	
	# Logo
	var logo = Sprite2D.new()
	logo.texture = load("res://Assets/Images/logo.jpg")
	logo.position = Vector2(270, 250)
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	logo.material = mat
	if logo.texture:
		var scale_ratio = 450.0 / logo.texture.get_width()
		logo.scale = Vector2(scale_ratio, scale_ratio)
	add_child(logo)
	
	# High Score Label
	var hs_label = Label.new()
	hs_label.text = "En Yüksek Puan: " + str(SaveManager.total_score)
	hs_label.add_theme_font_size_override("font_size", 30)
	hs_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	hs_label.add_theme_constant_override("outline_size", 4)
	hs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hs_label.size = Vector2(540, 50)
	hs_label.position = Vector2(0, get_viewport_rect().size.y * 0.45)
	add_child(hs_label)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.1, 0.5, 0.9)
	btn_style.corner_radius_top_left = 15
	btn_style.corner_radius_top_right = 15
	btn_style.corner_radius_bottom_left = 15
	btn_style.corner_radius_bottom_right = 15
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color(0.3, 0.15, 0.7, 1.0)
	
	var play_btn = Button.new()
	play_btn.text = "Oyuna Başla"
	play_btn.position = Vector2(120, get_viewport_rect().size.y * 0.55)
	play_btn.size = Vector2(300, 70)
	play_btn.add_theme_font_size_override("font_size", 32)
	play_btn.add_theme_stylebox_override("normal", btn_style)
	play_btn.add_theme_stylebox_override("hover", btn_style)
	play_btn.connect("pressed", Callable(self, "_on_play_pressed"))
	add_child(play_btn)
	
	var lb_btn = Button.new()
	lb_btn.text = "Sıralama"
	lb_btn.position = Vector2(120, get_viewport_rect().size.y * 0.65)
	lb_btn.size = Vector2(300, 70)
	lb_btn.add_theme_font_size_override("font_size", 32)
	lb_btn.add_theme_stylebox_override("normal", btn_style)
	lb_btn.add_theme_stylebox_override("hover", btn_style)
	lb_btn.connect("pressed", Callable(self, "_on_lb_pressed"))
	add_child(lb_btn)

func _on_play_pressed():
	_on_ad_closed_to_play()

func _on_ad_closed_to_play():
	get_tree().change_scene_to_file("res://Scenes/Main/Game.tscn")

func _on_lb_pressed():
	var lb = preload("res://Scenes/UI/LeaderboardUI.tscn").instantiate()
	lb.z_index = 100
	add_child(lb)

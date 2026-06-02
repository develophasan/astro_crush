extends Control

var list_container

func _ready():
	for child in get_children():
		child.queue_free()
		
	# Dark Overlay for the whole screen
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = Vector2(540, 960)
	add_child(overlay)
	
	# The stylish popup panel
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.1, 0.1, 0.25, 0.95)
	popup_style.border_width_left = 5
	popup_style.border_width_right = 5
	popup_style.border_width_top = 5
	popup_style.border_width_bottom = 5
	popup_style.border_color = Color(0.5, 0.3, 0.8, 1)
	popup_style.corner_radius_top_left = 20
	popup_style.corner_radius_top_right = 20
	popup_style.corner_radius_bottom_left = 20
	popup_style.corner_radius_bottom_right = 20
	
	var panel = Panel.new()
	panel.add_theme_stylebox_override("panel", popup_style)
	panel.size = Vector2(460, 700)
	panel.position = Vector2(40, 130)
	add_child(panel)
	
	var title = Label.new()
	title.text = "Sıralama"
	title.add_theme_font_size_override("font_size", 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 30)
	title.size = Vector2(460, 50)
	panel.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(20, 100)
	scroll.size = Vector2(420, 480)
	panel.add_child(scroll)
	
	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_container)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.1, 0.5, 0.9)
	btn_style.corner_radius_top_left = 15
	btn_style.corner_radius_top_right = 15
	btn_style.corner_radius_bottom_left = 15
	btn_style.corner_radius_bottom_right = 15
	
	var back_btn = Button.new()
	back_btn.text = "Geri Dön"
	back_btn.position = Vector2(130, 610)
	back_btn.size = Vector2(200, 60)
	back_btn.add_theme_font_size_override("font_size", 28)
	back_btn.add_theme_stylebox_override("normal", btn_style)
	back_btn.connect("pressed", Callable(self, "_on_back_pressed"))
	panel.add_child(back_btn)
	
	LeaderboardManager.connect("leaderboard_updated", Callable(self, "_on_data_received"))
	
	_show_loading()
	LeaderboardManager.fetch_leaderboard()

func _show_loading():
	for child in list_container.get_children():
		child.queue_free()
	var lbl = Label.new()
	lbl.text = "Yükleniyor..."
	lbl.add_theme_font_size_override("font_size", 24)
	list_container.add_child(lbl)

func _on_data_received(data):
	for child in list_container.get_children():
		child.queue_free()
		
	var rank = 1
	for entry in data:
		var row = HBoxContainer.new()
		
		var rank_lbl = Label.new()
		rank_lbl.text = str(rank) + "."
		rank_lbl.custom_minimum_size = Vector2(50, 0)
		rank_lbl.add_theme_font_size_override("font_size", 24)
		row.add_child(rank_lbl)
		
		var name_lbl = Label.new()
		name_lbl.text = entry["name"]
		name_lbl.custom_minimum_size = Vector2(250, 0)
		name_lbl.add_theme_font_size_override("font_size", 24)
		row.add_child(name_lbl)
		
		var score_lbl = Label.new()
		score_lbl.text = str(entry["score"])
		score_lbl.add_theme_font_size_override("font_size", 24)
		row.add_child(score_lbl)
		
		list_container.add_child(row)
		rank += 1

func _on_back_pressed():
	queue_free()

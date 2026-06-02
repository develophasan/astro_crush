extends Node2D

var grid
var score_label
var level_label
var moves_label
var target_label
var popup_panel
var settings_panel

var moves_left = 15
var target_score = 1000
var current_level_score = 0
var is_game_over = false

func _ready():
	_setup_ui()
	
	# Connect grid signals
	grid.connect("update_score", Callable(self, "_on_update_score"))
	grid.connect("move_made", Callable(self, "_on_move_made"))
	grid.connect("combo_achieved", Callable(self, "_on_combo_achieved"))
	grid.connect("bonus_achieved", Callable(self, "_on_bonus_achieved"))
	grid.connect("turn_ended", Callable(self, "_on_turn_ended"))
	
	_start_level()

func _setup_ui():
	# Create a simple UI dynamically if not present
	if not has_node("UI"):
		var ui = CanvasLayer.new()
		ui.name = "UI"
		add_child(ui)
		
		# Background
		var bg = TextureRect.new()
		bg.texture = load("res://Assets/Images/bg.jpg")
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_COVER
		bg.size = get_viewport_rect().size
		add_child(bg)
		
		var top_style = StyleBoxFlat.new()
		top_style.bg_color = Color(0.05, 0.05, 0.2, 0.85) # Deep space blue, slightly transparent
		top_style.corner_radius_bottom_left = 30
		top_style.corner_radius_bottom_right = 30
		top_style.border_width_bottom = 3
		top_style.border_color = Color(0.5, 0.3, 0.8, 0.9) # Purple neon edge
		top_style.shadow_size = 8
		
		var top_bar = Panel.new()
		top_bar.add_theme_stylebox_override("panel", top_style)
		top_bar.size = Vector2(540, 120)
		ui.add_child(top_bar)
		
		# Center Logo
		var logo = Sprite2D.new()
		logo.texture = load("res://Assets/Images/logo.jpg")
		logo.position = Vector2(270, 55) # Centered in the top bar
		var mat = CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		logo.material = mat
		if logo.texture:
			# Generative image is 1024x1024, crop the empty space roughly with scale
			var scale_ratio = 180.0 / logo.texture.get_height()
			logo.scale = Vector2(scale_ratio, scale_ratio)
		ui.add_child(logo)
		
		var bot_style = StyleBoxFlat.new()
		bot_style.bg_color = Color(0.05, 0.05, 0.2, 0.85)
		bot_style.corner_radius_top_left = 30
		bot_style.corner_radius_top_right = 30
		bot_style.border_width_top = 3
		bot_style.border_color = Color(0.5, 0.3, 0.8, 0.9)
		bot_style.shadow_size = 8
		
		var bottom_bar = Panel.new()
		bottom_bar.add_theme_stylebox_override("panel", bot_style)
		bottom_bar.size = Vector2(540, 130)
		bottom_bar.position = Vector2(0, get_viewport_rect().size.y - 130)
		ui.add_child(bottom_bar)
		
		score_label = Label.new()
		score_label.position = Vector2(20, 15)
		score_label.add_theme_font_size_override("font_size", 26)
		score_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		score_label.add_theme_constant_override("outline_size", 4)
		ui.add_child(score_label)
		
		level_label = Label.new()
		level_label.position = Vector2(20, 65)
		level_label.add_theme_font_size_override("font_size", 26)
		level_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		level_label.add_theme_constant_override("outline_size", 4)
		ui.add_child(level_label)
		
		moves_label = Label.new()
		moves_label.position = Vector2(360, 15)
		moves_label.add_theme_font_size_override("font_size", 26)
		moves_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		moves_label.add_theme_constant_override("outline_size", 4)
		ui.add_child(moves_label)
		
		target_label = Label.new()
		target_label.position = Vector2(360, 65)
		target_label.add_theme_font_size_override("font_size", 26)
		target_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		target_label.add_theme_constant_override("outline_size", 4)
		ui.add_child(target_label)
		
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.2, 0.1, 0.5, 0.9)
		btn_style.corner_radius_top_left = 15
		btn_style.corner_radius_top_right = 15
		btn_style.corner_radius_bottom_left = 15
		btn_style.corner_radius_bottom_right = 15
		btn_style.border_width_bottom = 4
		btn_style.border_color = Color(0.3, 0.15, 0.7, 1.0)
		
		var lb_btn = Button.new()
		lb_btn.text = "Sıralama"
		lb_btn.position = Vector2(70, 865)
		lb_btn.size = Vector2(160, 60)
		lb_btn.add_theme_font_size_override("font_size", 24)
		lb_btn.add_theme_stylebox_override("normal", btn_style)
		lb_btn.add_theme_stylebox_override("hover", btn_style)
		lb_btn.connect("pressed", Callable(self, "_on_lb_pressed"))
		ui.add_child(lb_btn)
		
		var share_btn = Button.new()
		share_btn.text = "Paylaş"
		share_btn.position = Vector2(310, 865)
		share_btn.size = Vector2(160, 60)
		share_btn.add_theme_font_size_override("font_size", 24)
		share_btn.add_theme_stylebox_override("normal", btn_style)
		share_btn.add_theme_stylebox_override("hover", btn_style)
		share_btn.connect("pressed", Callable(self, "_on_share_pressed"))
		ui.add_child(share_btn)
		
		# Popup Panel for Win/Lose
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
		
		popup_panel = Panel.new()
		popup_panel.add_theme_stylebox_override("panel", popup_style)
		popup_panel.size = Vector2(400, 300)
		popup_panel.position = Vector2(70, (get_viewport_rect().size.y - 300) / 2)
		popup_panel.visible = false
		ui.add_child(popup_panel)
		
		var popup_label = Label.new()
		popup_label.name = "Message"
		popup_label.text = "Bölüm Geçildi!"
		popup_label.position = Vector2(0, 50)
		popup_label.size = Vector2(400, 50)
		popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		popup_label.add_theme_font_size_override("font_size", 32)
		popup_panel.add_child(popup_label)
		
		var popup_btn = Button.new()
		popup_btn.name = "ActionBtn"
		popup_btn.text = "İleri"
		popup_btn.position = Vector2(100, 200)
		popup_btn.size = Vector2(200, 50)
		popup_btn.add_theme_font_size_override("font_size", 28)
		popup_btn.connect("pressed", Callable(self, "_on_popup_action"))
		popup_panel.add_child(popup_btn)
		
		# Settings Button
		var settings_btn = Button.new()
		settings_btn.text = "⚙"
		settings_btn.position = Vector2(480, 15)
		settings_btn.size = Vector2(50, 50)
		settings_btn.add_theme_font_size_override("font_size", 30)
		var s_style = StyleBoxFlat.new()
		s_style.bg_color = Color(0,0,0,0) # Transparent
		settings_btn.add_theme_stylebox_override("normal", s_style)
		settings_btn.connect("pressed", Callable(self, "_on_settings_pressed"))
		ui.add_child(settings_btn)
		
		# Settings Panel
		settings_panel = Panel.new()
		settings_panel.add_theme_stylebox_override("panel", popup_style)
		settings_panel.size = Vector2(400, 420)
		settings_panel.position = Vector2(70, 260)
		settings_panel.visible = false
		settings_panel.z_index = 50
		ui.add_child(settings_panel)
		
		var s_title = Label.new()
		s_title.text = "Ayarlar"
		s_title.position = Vector2(0, 30)
		s_title.size = Vector2(400, 40)
		s_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s_title.add_theme_font_size_override("font_size", 32)
		settings_panel.add_child(s_title)
		
		var music_chk = CheckButton.new()
		music_chk.text = "Müzik"
		music_chk.button_pressed = AudioManager.music_enabled
		music_chk.position = Vector2(120, 100)
		music_chk.add_theme_font_size_override("font_size", 24)
		music_chk.connect("toggled", Callable(self, "_on_music_toggled"))
		settings_panel.add_child(music_chk)
		
		var sfx_chk = CheckButton.new()
		sfx_chk.text = "Ses Efekti"
		sfx_chk.button_pressed = AudioManager.sfx_enabled
		sfx_chk.position = Vector2(120, 160)
		sfx_chk.add_theme_font_size_override("font_size", 24)
		sfx_chk.connect("toggled", Callable(self, "_on_sfx_toggled"))
		settings_panel.add_child(sfx_chk)
		
		var menu_btn = Button.new()
		menu_btn.text = "Ana Menü"
		menu_btn.position = Vector2(50, 240)
		menu_btn.size = Vector2(140, 50)
		menu_btn.add_theme_stylebox_override("normal", btn_style)
		menu_btn.add_theme_font_size_override("font_size", 22)
		menu_btn.connect("pressed", Callable(self, "_on_menu_pressed"))
		settings_panel.add_child(menu_btn)
		
		var close_btn = Button.new()
		close_btn.text = "Kapat"
		close_btn.position = Vector2(210, 240)
		close_btn.size = Vector2(140, 50)
		close_btn.add_theme_stylebox_override("normal", btn_style)
		close_btn.add_theme_font_size_override("font_size", 22)
		close_btn.connect("pressed", Callable(self, "_on_close_settings_pressed"))
		settings_panel.add_child(close_btn)
		
		var privacy_btn = Button.new()
		privacy_btn.text = "Gizlilik Politikası (Privacy Policy)"
		privacy_btn.position = Vector2(50, 320)
		privacy_btn.size = Vector2(300, 50)
		var p_style = btn_style.duplicate()
		p_style.bg_color = Color(0.1, 0.4, 0.2, 0.9)
		p_style.border_color = Color(0.2, 0.6, 0.3, 1.0)
		privacy_btn.add_theme_stylebox_override("normal", p_style)
		privacy_btn.add_theme_font_size_override("font_size", 18)
		privacy_btn.connect("pressed", Callable(self, "_on_privacy_pressed"))
		settings_panel.add_child(privacy_btn)
		
		var grid_node = Node2D.new()
		grid_node.name = "Grid"
		grid_node.set_script(preload("res://Scripts/Grid.gd"))
		grid_node.x_start = 46
		grid_node.y_start = 700
		add_child(grid_node)
		grid = grid_node

func _start_level():
	is_game_over = false
	popup_panel.visible = false
	current_level_score = 0
	
	moves_left = 15 + int(SaveManager.current_level / 2.0)
	target_score = 1000 + int(SaveManager.current_level * 500)
	
	_update_ui()
	
	for child in grid.get_children():
		child.queue_free()
	grid.all_pieces = grid._make_2d_array()
	grid.spawn_pieces()
	grid.state = grid.PLAY

func _update_ui():
	score_label.text = "Puan: " + str(int(current_level_score))
	level_label.text = "Seviye: " + str(int(SaveManager.current_level))
	moves_label.text = "Hamle: " + str(int(moves_left))
	target_label.text = "Hedef: " + str(int(target_score))

func _on_update_score(points):
	current_level_score += points
	_update_ui()

func _on_move_made():
	if not is_game_over:
		moves_left -= 1
		_update_ui()

func _on_turn_ended():
	if is_game_over: return
	
	if current_level_score >= target_score:
		_show_popup(true)
	elif moves_left <= 0:
		_show_popup(false)

func _show_popup(win: bool):
	is_game_over = true
	grid.state = grid.WAIT # Stop input
	popup_panel.visible = true
	var msg = popup_panel.get_node("Message")
	var btn = popup_panel.get_node("ActionBtn")
	if win:
		msg.text = "Seviye " + str(SaveManager.current_level) + "\nTamamlandı!"
		btn.text = "Sıradaki Bölüm"
		SaveManager.add_score(current_level_score)
	else:
		msg.text = "Hamle Bitti!"
		btn.text = "Tekrar Dene"

func _on_popup_action():
	if popup_panel.get_node("ActionBtn").text == "Sıradaki Bölüm":
		SaveManager.level_up()
	_on_ad_closed_to_continue()

func _on_ad_closed_to_continue():
	_start_level()

func _on_settings_pressed():
	if not is_game_over:
		grid.state = grid.WAIT
		settings_panel.visible = true

func _on_music_toggled(button_pressed):
	AudioManager.set_music(button_pressed)

func _on_sfx_toggled(button_pressed):
	AudioManager.set_sfx(button_pressed)

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _on_close_settings_pressed():
	settings_panel.visible = false
	if not is_game_over:
		grid.state = grid.PLAY

func _on_privacy_pressed():
	OS.shell_open("https://policies.google.com/privacy")

func _on_bonus_achieved(matched_count):
	var float_text = Label.new()
	if matched_count == 4:
		float_text.text = "Süper!"
	elif matched_count >= 5:
		float_text.text = "Harika!"
	
	float_text.add_theme_font_size_override("font_size", 45)
	float_text.add_theme_color_override("font_color", Color(0, 1, 0)) # Green
	float_text.position = Vector2(200, 400)
	$UI.add_child(float_text)
	
	var tween = get_tree().create_tween()
	tween.tween_property(float_text, "scale", Vector2(1.5, 1.5), 0.5)
	tween.parallel().tween_property(float_text, "position", float_text.position - Vector2(20, 50), 0.5)
	tween.tween_property(float_text, "modulate:a", 0.0, 0.5)
	tween.tween_callback(float_text.queue_free)

func _on_combo_achieved(multiplier, pos):
	var float_text = Label.new()
	float_text.text = "Kombo x" + str(multiplier) + "!"
	float_text.add_theme_font_size_override("font_size", 40)
	float_text.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
	float_text.position = pos - Vector2(100, 20)
	$UI.add_child(float_text)
	
	var tween = get_tree().create_tween()
	tween.tween_property(float_text, "position", float_text.position - Vector2(0, 100), 1.0)
	tween.parallel().tween_property(float_text, "modulate:a", 0.0, 1.0)
	tween.tween_callback(float_text.queue_free)

func _on_share_pressed():
	ShareManager.share_score(SaveManager.total_score, SaveManager.current_level)

func _on_lb_pressed():
	LeaderboardManager.submit_score(SaveManager.player_name, SaveManager.total_score, SaveManager.current_level)
	var lb = preload("res://Scenes/UI/LeaderboardUI.tscn").instantiate()
	lb.z_index = 100
	$UI.add_child(lb)

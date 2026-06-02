extends Node2D

func _ready():
	# Create background
	var bg = Sprite2D.new()
	bg.texture = load("res://Assets/Images/bg.jpg")
	bg.position = Vector2(270, 480)
	if bg.texture:
		var scale_x = 540.0 / bg.texture.get_width()
		var scale_y = 960.0 / bg.texture.get_height()
		var final_scale = max(scale_x, scale_y)
		bg.scale = Vector2(final_scale, final_scale)
	add_child(bg)
	
	# Falling pieces effect
	for i in range(25):
		_spawn_falling_piece()
		
	# Create logo
	var logo = Sprite2D.new()
	logo.texture = load("res://Assets/Images/logo.jpg")
	logo.position = Vector2(270, 480)
	var mat = CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	logo.material = mat
	if logo.texture:
		var scale_ratio = 450.0 / logo.texture.get_width()
		logo.scale = Vector2(scale_ratio, scale_ratio)
	logo.modulate.a = 0.0
	add_child(logo)
	
	# Logo fade in and out
	var tween = get_tree().create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, 1.5)
	tween.tween_interval(1.5)
	tween.tween_property(logo, "modulate:a", 0.0, 1.0)
	tween.tween_callback(Callable(self, "_on_splash_done"))

func _spawn_falling_piece():
	var piece = Sprite2D.new()
	piece.texture = load("res://Assets/Images/pieces.jpg")
	var mat = ShaderMaterial.new()
	mat.shader = load("res://Scripts/remove_bg.gdshader")
	piece.material = mat
	
	# Random region
	var color = ["red", "blue", "green", "purple", "yellow", "star"].pick_random()
	var region = Rect2(40, 150, 300, 300)
	match color:
		"red": region = Rect2(40, 150, 300, 300)
		"blue": region = Rect2(360, 150, 300, 300)
		"green": region = Rect2(680, 150, 300, 300)
		"purple": region = Rect2(200, 550, 300, 300)
		"yellow": region = Rect2(500, 550, 300, 300)
		"star": region = Rect2(800, 550, 200, 200)
	piece.region_enabled = true
	piece.region_rect = region
	piece.scale = Vector2(0.3, 0.3)
	piece.modulate.a = randf_range(0.2, 0.5) # Faint
	
	piece.position = Vector2(randf_range(20, 520), randf_range(-1000, 960))
	add_child(piece)
	
	var tween = get_tree().create_tween()
	var duration = randf_range(4.0, 8.0)
	# Pieces flow downwards
	tween.tween_property(piece, "position:y", piece.position.y + 1200, duration)
	tween.tween_callback(piece.queue_free)

func _on_splash_done():
	get_tree().change_scene_to_file("res://Scenes/Main/IntroVideo.tscn")

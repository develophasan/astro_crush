extends Node2D
class_name Piece

@export var color: String
var matched: bool = false
var column: int
var row: int

@onready var sprite = $Sprite2D

func _ready():
	pass

func init(new_color: String, col: int, r: int):
	color = new_color
	column = col
	row = r
	position = Vector2(column * 64 + 32, row * 64 + 32)
	
	if not has_node("Sprite2D"):
		var s = Sprite2D.new()
		s.name = "Sprite2D"
		add_child(s)
		sprite = s
	
	_set_texture_based_on_color()

func _set_texture_based_on_color():
	var tex = load("res://Assets/Images/pieces.jpg")
	if tex:
		# Assuming pieces.png is a 5x1 or something, or we can use AtlasTexture
		# Since we don't have exact coordinates, let's just make a basic Region based on color
		# Let's say the image is 500x100, each piece is 100x100.
		# I will mock the region rects for now. We can adjust them.
		var region = Rect2(0, 0, 100, 100)
		match color:
			"red": region = Rect2(20, 120, 360, 360)
			"blue": region = Rect2(340, 120, 360, 360)
			"green": region = Rect2(650, 120, 360, 360)
			"purple": region = Rect2(180, 500, 360, 360)
			"yellow": region = Rect2(520, 500, 360, 360)
		
		# Set Region
		sprite.texture = tex
		sprite.region_enabled = true
		sprite.region_rect = region
		
		# Use ShaderMaterial to key out the dark gray background
		var mat = ShaderMaterial.new()
		mat.shader = load("res://Scripts/remove_bg.gdshader")
		sprite.material = mat
		
		# Scale down based on 360 region to fit comfortably in 64 grid
		sprite.scale = Vector2(64.0 / region.size.x, 64.0 / region.size.y)

func move_to(target_pos: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func make_matched():
	matched = true
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)

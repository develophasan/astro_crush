extends Node2D
class_name Grid

@export var width: int = 8
@export var height: int = 8
@export var x_start: int = 64
@export var y_start: int = 800
@export var offset: int = 64
@export var y_offset: int = 2

var possible_pieces = ["red", "blue", "green", "purple", "yellow"]
var all_pieces = []

enum { WAIT, PLAY }
var state = PLAY

var first_touch = Vector2.ZERO
var final_touch = Vector2.ZERO
var controlling = false

var piece_one = null
var piece_two = null

@onready var piece_scene = preload("res://Scenes/Pieces/Piece.tscn")

signal update_score(points)
signal move_made
signal combo_achieved(multiplier, position)
signal bonus_achieved(matched_count)
signal turn_ended

var combo_multiplier = 1

func _ready():
	randomize()
	all_pieces = _make_2d_array()
	spawn_pieces()

func _make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func spawn_pieces():
	for i in width:
		for j in height:
			var rand = randi() % possible_pieces.size()
			var piece_color = possible_pieces[rand]
			
			# Prevent matches on spawn
			while match_at(i, j, piece_color):
				rand = randi() % possible_pieces.size()
				piece_color = possible_pieces[rand]
			
			var piece = piece_scene.instantiate()
			add_child(piece)
			piece.init(piece_color, i, j)
			piece.position = grid_to_pixel(i, j - y_offset)
			piece.move_to(grid_to_pixel(i, j))
			all_pieces[i][j] = piece

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null and all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color and all_pieces[i-2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null and all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color and all_pieces[i][j-2].color == color:
				return true
	return false

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_grid(column, row):
	if column >= 0 and column < width and row >= 0 and row < height:
		return true
	return false

func touch_input():
	if state != PLAY:
		return
		
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var grid_pos = pixel_to_grid(first_touch.x, first_touch.y)
		if is_in_grid(grid_pos.x, grid_pos.y):
			controlling = true
	
	if Input.is_action_just_released("ui_touch"):
		if controlling:
			final_touch = get_global_mouse_position()
			var grid_pos = pixel_to_grid(first_touch.x, first_touch.y)
			touch_difference(grid_pos.x, grid_pos.y)
			controlling = false

func touch_difference(column, row):
	var difference = final_touch - first_touch
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(column, row, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(column, row, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(column, row, Vector2(0, -1)) # y increases downwards in pixel, but row increases upwards in grid_to_pixel (y_start - offset*row)
		elif difference.y < 0:
			swap_pieces(column, row, Vector2(0, 1))

func swap_pieces(column, row, direction):
	var other_column = column + direction.x
	var other_row = row + direction.y
	if is_in_grid(other_column, other_row):
		if all_pieces[column][row] != null and all_pieces[other_column][other_row] != null:
			piece_one = all_pieces[column][row]
			piece_two = all_pieces[other_column][other_row]
			
			# Swap in grid
			all_pieces[column][row] = piece_two
			all_pieces[other_column][other_row] = piece_one
			
			state = WAIT
			combo_multiplier = 1 # Reset combo on new move
			
			# Update piece variables
			piece_one.column = other_column
			piece_one.row = other_row
			piece_two.column = column
			piece_two.row = row
			
			# Visual move
			piece_one.move_to(grid_to_pixel(piece_one.column, piece_one.row))
			piece_two.move_to(grid_to_pixel(piece_two.column, piece_two.row))
			
			get_tree().create_timer(0.4).connect("timeout", Callable(self, "check_matches_after_swap"))
			emit_signal("move_made")
			AudioManager.play_swap()

func check_matches_after_swap():
	find_matches()
	if not destroy_matches():
		# Revert swap
		var col1 = piece_one.column
		var row1 = piece_one.row
		var col2 = piece_two.column
		var row2 = piece_two.row
		
		all_pieces[col2][row2] = piece_one
		all_pieces[col1][row1] = piece_two
		
		piece_one.column = col2
		piece_one.row = row2
		piece_two.column = col1
		piece_two.row = row1
		
		piece_one.move_to(grid_to_pixel(piece_one.column, piece_one.row))
		piece_two.move_to(grid_to_pixel(piece_two.column, piece_two.row))
		
		# Allow playing again after revert animation
		get_tree().create_timer(0.4).connect("timeout", Callable(self, "_set_state_play"))

func _set_state_play():
	state = PLAY

func _process(_delta):
	touch_input()

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 and i < width - 1:
					if all_pieces[i-1][j] != null and all_pieces[i+1][j] != null:
						if all_pieces[i-1][j].color == current_color and all_pieces[i+1][j].color == current_color:
							all_pieces[i-1][j].matched = true
							all_pieces[i][j].matched = true
							all_pieces[i+1][j].matched = true
				if j > 0 and j < height - 1:
					if all_pieces[i][j-1] != null and all_pieces[i][j+1] != null:
						if all_pieces[i][j-1].color == current_color and all_pieces[i][j+1].color == current_color:
							all_pieces[i][j-1].matched = true
							all_pieces[i][j].matched = true
							all_pieces[i][j+1].matched = true

func destroy_matches():
	var was_matched = false
	var score_add = 0
	var destroyed_count = 0
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				was_matched = true
				all_pieces[i][j].make_matched()
				all_pieces[i][j] = null
				score_add += 10
				destroyed_count += 1
	
	if was_matched:
		AudioManager.play_match()
		if destroyed_count == 4:
			score_add += 100
			emit_signal("bonus_achieved", 4)
		elif destroyed_count >= 5:
			score_add += 300
			emit_signal("bonus_achieved", 5)
			
		var final_score = score_add * combo_multiplier
		emit_signal("update_score", final_score)
		if combo_multiplier > 1:
			emit_signal("combo_achieved", combo_multiplier, Vector2(540.0/2.0, 960.0/2.0)) # Emit in screen center approx
		get_tree().create_timer(0.3).connect("timeout", Callable(self, "collapse_columns"))
	return was_matched

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move_to(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][j].row = j
						all_pieces[i][k] = null
						break
	
	get_tree().create_timer(0.3).connect("timeout", Callable(self, "refill_board"))

func refill_board():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = randi() % possible_pieces.size()
				var piece_color = possible_pieces[rand]
				
				var piece = piece_scene.instantiate()
				add_child(piece)
				piece.init(piece_color, i, j)
				piece.position = grid_to_pixel(i, j + y_offset)
				piece.move_to(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
	
	# Check again after refill (cascading matches)
	get_tree().create_timer(0.4).connect("timeout", Callable(self, "check_cascade"))

func check_cascade():
	find_matches()
	var had_matches = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null and all_pieces[i][j].matched:
				had_matches = true
				break
	
	if had_matches:
		combo_multiplier += 1
		destroy_matches()
	else:
		state = PLAY
		emit_signal("turn_ended")

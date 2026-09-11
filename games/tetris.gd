extends Node2D

# Tetris Block Shapes (Tetrominoes)
var shapes = [
	[[1, 1, 1, 1]],  # I
	[[1, 1], [1, 1]],  # O
	[[0, 1, 1], [1, 1, 0]],  # S
	[[1, 1, 0], [0, 1, 1]],  # Z
	[[1, 0, 0], [1, 1, 1]],  # J
	[[0, 0, 1], [1, 1, 1]],  # L
	[[0, 1, 0], [1, 1, 1]],  # T
]

const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const BLOCK_SIZE = 30

var grid = []
var current_piece = null
var current_x = 3
var current_y = 0
var score = 0
var game_over = false
var fall_speed = 0.5
var fall_timer = 0.0

func _ready():
	set_process(true)
	set_process_input(true)
	# Initialize grid
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(0)
		grid.append(row)
	
	spawn_piece()

func _process(delta):
	if game_over:
		return
	
	fall_timer += delta
	if fall_timer >= fall_speed:
		fall_timer = 0.0
		if not move_piece(0, 1):
			freeze_piece()
			spawn_piece()
	
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_left"):
		move_piece(-1, 0)
	elif event.is_action_pressed("ui_right"):
		move_piece(1, 0)
	elif event.is_action_pressed("ui_down"):
		move_piece(0, 1)
	
	if event.is_action_pressed("ui_accept") and game_over:
		get_tree().reload_current_scene()

func spawn_piece():
	var random_shape = shapes[randi() % shapes.size()]
	current_piece = random_shape
	current_x = 3
	current_y = 0
	
	if not can_place(current_x, current_y):
		game_over = true

func move_piece(dx: int, dy: int) -> bool:
	if can_place(current_x + dx, current_y + dy):
		current_x += dx
		current_y += dy
		return true
	return false

func can_place(x: int, y: int) -> bool:
	for row in range(current_piece.size()):
		for col in range(current_piece[row].size()):
			if current_piece[row][col] == 1:
				var grid_x = x + col
				var grid_y = y + row
				
				if grid_x < 0 or grid_x >= GRID_WIDTH or grid_y >= GRID_HEIGHT:
					return false
				
				if grid_y >= 0 and grid[grid_y][grid_x] == 1:
					return false
	
	return true

func freeze_piece():
	for row in range(current_piece.size()):
		for col in range(current_piece[row].size()):
			if current_piece[row][col] == 1:
				var grid_x = current_x + col
				var grid_y = current_y + row
				
				if grid_y >= 0:
					grid[grid_y][grid_x] = 1
	
	check_lines()

func check_lines():
	var lines_to_clear = []
	
	for y in range(GRID_HEIGHT):
		var full = true
		for x in range(GRID_WIDTH):
			if grid[y][x] == 0:
				full = false
				break
		
		if full:
			lines_to_clear.append(y)
	
	for y in lines_to_clear.size():
		grid.remove_at(lines_to_clear[y] - y)
		var new_row = []
		for x in range(GRID_WIDTH):
			new_row.append(0)
		grid.insert(0, new_row)
	
	score += lines_to_clear.size() * 100

func _draw():
	# Draw grid background
	var bg = Rect2(0, 0, GRID_WIDTH * BLOCK_SIZE, GRID_HEIGHT * BLOCK_SIZE)
	draw_rect(bg, Color.BLACK)
	
	# Draw placed blocks
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] == 1:
				var rect = Rect2(x * BLOCK_SIZE, y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE)
				draw_rect(rect, Color.CYAN)
				draw_rect(Rect2(x * BLOCK_SIZE + 1, y * BLOCK_SIZE + 1, BLOCK_SIZE - 2, BLOCK_SIZE - 2), Color.DARK_CYAN)
	
	# Draw current piece
	for row in range(current_piece.size()):
		for col in range(current_piece[row].size()):
			if current_piece[row][col] == 1:
				var x = (current_x + col) * BLOCK_SIZE
				var y = (current_y + row) * BLOCK_SIZE
				var rect = Rect2(x, y, BLOCK_SIZE, BLOCK_SIZE)
				draw_rect(rect, Color.YELLOW)
				draw_rect(Rect2(x + 1, y + 1, BLOCK_SIZE - 2, BLOCK_SIZE - 2), Color.WHITE)
	
	# Draw score
	draw_string(ThemeDB.fallback_font, Vector2(GRID_WIDTH * BLOCK_SIZE + 20, 20), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	
	if game_over:
		draw_string(ThemeDB.fallback_font, Vector2(GRID_WIDTH * BLOCK_SIZE / 2 - 80, GRID_HEIGHT * BLOCK_SIZE / 2), "GAME OVER!", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.RED)

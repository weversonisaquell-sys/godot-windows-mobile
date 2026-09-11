extends Node2D

const GRID_SIZE = 20
const GRID_WIDTH = 40
const GRID_HEIGHT = 30

var snake = [Vector2(20, 15)]
var direction = Vector2(1, 0)
var next_direction = Vector2(1, 0)
var food = Vector2(25, 15)
var score = 0
var game_over = false
var game_speed = 0.1
var time_since_last_move = 0.0

func _ready():
	set_process(true)
	set_process_input(true)
	randomize()
	spawn_food()

func _process(delta):
	if game_over:
		return
	
	time_since_last_move += delta
	
	if time_since_last_move >= game_speed:
		time_since_last_move = 0.0
		direction = next_direction
		
		var new_head = snake[0] + direction
		
		# Check collisions
		if new_head.x < 0 or new_head.x >= GRID_WIDTH or new_head.y < 0 or new_head.y >= GRID_HEIGHT:
			game_over = true
			return
		
		if new_head in snake:
			game_over = true
			return
		
		snake.insert(0, new_head)
		
		# Check food
		if new_head == food:
			score += 10
			spawn_food()
		else:
			snake.pop_back()
	
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_up") and direction.y == 0:
		next_direction = Vector2(0, -1)
	elif event.is_action_pressed("ui_down") and direction.y == 0:
		next_direction = Vector2(0, 1)
	elif event.is_action_pressed("ui_left") and direction.x == 0:
		next_direction = Vector2(-1, 0)
	elif event.is_action_pressed("ui_right") and direction.x == 0:
		next_direction = Vector2(1, 0)
	
	if event.is_action_pressed("ui_accept") and game_over:
		get_tree().reload_current_scene()

func spawn_food():
	food = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)
	while food in snake:
		food = Vector2(randi() % GRID_WIDTH, randi() % GRID_HEIGHT)

func _draw():
	# Draw grid
	for segment in snake:
		var rect = Rect2(segment.x * GRID_SIZE, segment.y * GRID_SIZE, GRID_SIZE - 2, GRID_SIZE - 2)
		draw_rect(rect, Color.GREEN)
	
	# Draw food
	var food_rect = Rect2(food.x * GRID_SIZE, food.y * GRID_SIZE, GRID_SIZE - 2, GRID_SIZE - 2)
	draw_rect(food_rect, Color.RED)
	
	# Draw score
	draw_string(ThemeDB.fallback_font, Vector2(10, 20), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	
	if game_over:
		draw_string(ThemeDB.fallback_font, Vector2(150, 250), "GAME OVER!", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color.RED)

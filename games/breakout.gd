extends Node2D

const PADDLE_WIDTH = 100
const PADDLE_HEIGHT = 10
const BALL_RADIUS = 5
const BLOCK_WIDTH = 50
const BLOCK_HEIGHT = 20

var paddle_x = 0
var ball_pos = Vector2(640, 360)
var ball_velocity = Vector2(300, -300)
var score = 0
var blocks = []
var game_over = false

func _ready():
	set_process(true)
	set_process_input(true)
	paddle_x = get_viewport_rect().size.x / 2 - PADDLE_WIDTH / 2
	
	# Create blocks
	for row in range(3):
		for col in range(8):
			blocks.append(Rect2(col * (BLOCK_WIDTH + 10) + 50, row * (BLOCK_HEIGHT + 10) + 50, BLOCK_WIDTH, BLOCK_HEIGHT))

func _process(delta):
	if game_over:
		return
	
	# Ball movement
	ball_pos += ball_velocity * delta
	
	# Ball boundaries
	if ball_pos.x - BALL_RADIUS <= 0 or ball_pos.x + BALL_RADIUS >= get_viewport_rect().size.x:
		ball_velocity.x *= -1
	
	if ball_pos.y - BALL_RADIUS <= 0:
		ball_velocity.y *= -1
	
	if ball_pos.y > get_viewport_rect().size.y:
		game_over = true
	
	# Paddle collision
	var paddle_rect = Rect2(paddle_x, get_viewport_rect().size.y - PADDLE_HEIGHT - 20, PADDLE_WIDTH, PADDLE_HEIGHT)
	if ball_pos.distance_to(paddle_rect.get_center()) < BALL_RADIUS + PADDLE_WIDTH / 2:
		ball_velocity.y *= -1
	
	# Block collision
	for block in blocks:
		if block.has_point(ball_pos):
			blocks.erase(block)
			ball_velocity.y *= -1
			score += 10
			break
	
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_left"):
		paddle_x -= 30
	elif event.is_action_pressed("ui_right"):
		paddle_x += 30
	
	paddle_x = clamp(paddle_x, 0, get_viewport_rect().size.x - PADDLE_WIDTH)
	
	if event.is_action_pressed("ui_accept") and game_over:
		get_tree().reload_current_scene()

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, get_viewport_rect().size.x, get_viewport_rect().size.y), Color.BLACK)
	
	# Draw blocks
	for block in blocks:
		draw_rect(block, Color.CYAN)
		draw_rect(block.grow(-2), Color.DARK_CYAN)
	
	# Draw paddle
	draw_rect(Rect2(paddle_x, get_viewport_rect().size.y - PADDLE_HEIGHT - 20, PADDLE_WIDTH, PADDLE_HEIGHT), Color.WHITE)
	
	# Draw ball
	draw_circle(ball_pos, BALL_RADIUS, Color.WHITE)
	
	# Draw score
	draw_string(ThemeDB.fallback_font, Vector2(20, 30), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	
	if game_over:
		draw_string(ThemeDB.fallback_font, Vector2(get_viewport_rect().size.x / 2 - 100, get_viewport_rect().size.y / 2), "GAME OVER!", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color.RED)

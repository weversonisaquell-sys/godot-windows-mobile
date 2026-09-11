extends Node2D

const PADDLE_WIDTH = 80
const PADDLE_HEIGHT = 10
const BALL_RADIUS = 5

var left_paddle_y = 0
var right_paddle_y = 0
var ball_pos = Vector2(640, 360)
var ball_velocity = Vector2(300, 300)
var left_score = 0
var right_score = 0
var game_over = false

func _ready():
	set_process(true)
	set_process_input(true)


func _process(delta):
	if game_over:
		return
	
	# AI paddle movement
	if ball_pos.y < right_paddle_y + PADDLE_HEIGHT / 2:
		right_paddle_y -= 250 * delta
	elif ball_pos.y > right_paddle_y + PADDLE_HEIGHT / 2:
		right_paddle_y += 250 * delta
	
	right_paddle_y = clamp(right_paddle_y, 0, get_viewport_rect().size.y - PADDLE_HEIGHT)
	left_paddle_y = clamp(left_paddle_y, 0, get_viewport_rect().size.y - PADDLE_HEIGHT)
	
	# Ball movement
	ball_pos += ball_velocity * delta
	
	# Ball boundaries
	if ball_pos.y - BALL_RADIUS <= 0 or ball_pos.y + BALL_RADIUS >= get_viewport_rect().size.y:
		ball_velocity.y *= -1
	
	# Paddle collisions
	if ball_pos.x - BALL_RADIUS <= 0 + PADDLE_WIDTH and ball_pos.y >= left_paddle_y and ball_pos.y <= left_paddle_y + PADDLE_HEIGHT:
		ball_velocity.x *= -1
	
	if ball_pos.x + BALL_RADIUS >= get_viewport_rect().size.x - PADDLE_WIDTH and ball_pos.y >= right_paddle_y and ball_pos.y <= right_paddle_y + PADDLE_HEIGHT:
		ball_velocity.x *= -1
	
	# Score
	if ball_pos.x < 0:
		right_score += 1
		ball_pos = Vector2(640, 360)
		ball_velocity = Vector2(-300, 300)
	
	if ball_pos.x > get_viewport_rect().size.x:
		left_score += 1
		ball_pos = Vector2(640, 360)
		ball_velocity = Vector2(300, 300)
	
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_up"):
		left_paddle_y -= 20
	elif event.is_action_pressed("ui_down"):
		left_paddle_y += 20

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, get_viewport_rect().size.x, get_viewport_rect().size.y), Color.BLACK)
	
	# Draw paddles
	draw_rect(Rect2(10, left_paddle_y, PADDLE_WIDTH, PADDLE_HEIGHT), Color.WHITE)
	draw_rect(Rect2(get_viewport_rect().size.x - PADDLE_WIDTH - 10, right_paddle_y, PADDLE_WIDTH, PADDLE_HEIGHT), Color.WHITE)
	
	# Draw ball
	draw_circle(ball_pos, BALL_RADIUS, Color.WHITE)
	
	# Draw score
	draw_string(ThemeDB.fallback_font, Vector2(get_viewport_rect().size.x / 2 - 50, 30), "%d : %d" % [left_score, right_score], HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)

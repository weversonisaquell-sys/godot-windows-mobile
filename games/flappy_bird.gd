extends Node2D

var bird_pos = Vector2(100, 300)
var bird_velocity = 0.0
var gravity = 500.0
var jump_force = -300.0
var pipes = []
var score = 0
var game_over = false

func _ready():
	set_process(true)
	set_process_input(true)

func _process(delta):
	if game_over:
		return
	
	# Physics
	bird_velocity += gravity * delta
	bird_pos.y += bird_velocity * delta
	
	# Boundaries
	if bird_pos.y > get_viewport_rect().size.y or bird_pos.y < 0:
		game_over = true
	
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		bird_velocity = jump_force
	
	if event.is_action_pressed("ui_accept"):
		if game_over:
			get_tree().reload_current_scene()

func _draw():
	# Draw bird
	draw_circle(bird_pos, 10, Color.YELLOW)
	
	# Draw score
	draw_string(ThemeDB.fallback_font, Vector2(20, 30), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	
	if game_over:
		draw_string(ThemeDB.fallback_font, Vector2(get_viewport_rect().size.x / 2 - 50, get_viewport_rect().size.y / 2), "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.RED)

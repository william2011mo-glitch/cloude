extends CanvasLayer
@onready var small: Timer = $smallMovement
@onready var large: Timer = $largeMovement
var shake_pos
var move_amount = 500
var moving = false
var base_pos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_pos = Vector2(DisplayServer.window_get_size())/2
	small.timeout.connect(move_mouse_small)
	large.timeout.connect(move_mouse_large)
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion and not moving:
		base_pos = Vector2(DisplayServer.mouse_get_position()) - Vector2(DisplayServer.window_get_position())
		small.stop()
		small.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func move_mouse_small():
	moving = true
	var target = (Vector2(base_pos.x+randf_range(-100, 100), base_pos.y+randf_range(-100, 100)))
	var tween = create_tween()
	tween.tween_method(func(pos): Input.warp_mouse(pos), base_pos, target, 0.05)
	tween.finished.connect(func(): moving = false)

func move_mouse_large():
	var screen_size = Vector2(DisplayServer.window_get_size())
	var side = randi()%4
	var target = Vector2(0, 0)
	if side == 0:  # top
		target = Vector2(randf_range(0, screen_size.x), 0)
	elif side == 1:  # bottom
		target = Vector2(randf_range(0, screen_size.x), screen_size.y)
	elif side == 2:  # left
		target = Vector2(0, randf_range(0, screen_size.y))
	else:  # right
		target = Vector2(screen_size.x, randf_range(0, screen_size.y))
	moving = true
	var tween = create_tween()
	tween.tween_method(func(pos): Input.warp_mouse(pos), base_pos, target, 0.06)
	base_pos = target
	tween.finished.connect(func(): moving = false)

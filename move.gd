extends ColorRect

var speed = randi() % 4 + 1
var time_passed = 0
var is_done = false

func _ready() -> void:
	$target.set_position(Vector2($target.get_screen_position().x+(randi() % 450 - 900), 0.0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta*speed
	$Mover.set_position(Vector2(sin(time_passed)*450+450, 0.0))
	if Input.is_action_just_pressed("ui_accept"):
		var rect1 = $Mover.get_global_rect()
		var rect2 = $target.get_global_rect()
		if rect1.intersects(rect2):
			speed = 0
			color = Color(0.893, 0.709, 0.269, 1.0)
			is_done = true

extends CanvasLayer

const TOLERANCE := 20.0
const POINT_SPACING := 8.0

var shape_points: PackedVector2Array = []
var traced := []
var game_over := false
var won := false

var draw_control: Control
var status_label: Label


func _ready():
	randomize()

	draw_control = Control.new()
	draw_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(draw_control)

	status_label = Label.new()
	status_label.position = Vector2(20, 20)
	status_label.text = "Trace the shape"
	add_child(status_label)

	draw_control.draw.connect(_on_draw)

	_generate_random_shape()

	traced.resize(shape_points.size())
	traced.fill(false)


func _process(_delta):
	draw_control.queue_redraw()

	if game_over:
		return

	var mouse := get_viewport().get_mouse_position()

	var closest_idx := -1
	var closest_dist := INF

	for i in shape_points.size():
		var d = mouse.distance_to(shape_points[i])

		if d < closest_dist:
			closest_dist = d
			closest_idx = i

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		if closest_dist > TOLERANCE:
			game_over = true
			won = false
			status_label.text = "FAILED - Press R"
			queue_free()

		traced[closest_idx] = true

		var completed := 0

		for t in traced:
			if t:
				completed += 1

		var pct := int(100.0 * completed / traced.size())
		status_label.text = "Progress: %d%%" % pct

		if completed > traced.size() * 0.98:
			game_over = true
			won = true
			status_label.text = "YOU WIN - Press R"
			queue_free()
	if Input.is_key_pressed(KEY_R):
		_restart()


func _restart():
	game_over = false
	won = false

	_generate_random_shape()

	traced.resize(shape_points.size())
	traced.fill(false)

	status_label.text = "Trace the shape"


func _generate_random_shape():
	var center = get_viewport().get_visible_rect().size / 2.0

	match randi() % 4:
		0:
			shape_points = _circle(center, 150)

		1:
			shape_points = _star(center, 150, 70, 5)

		2:
			shape_points = _polygon(center, 150, 3)

		3:
			shape_points = _circle(center, 150)


func _circle(center: Vector2, radius: float) -> PackedVector2Array:
	var pts := PackedVector2Array()

	for i in range(80):
		var a = TAU * i / 80.0
		pts.append(center + Vector2(cos(a), sin(a)) * radius)

	return pts


func _polygon(center: Vector2, radius: float, sides: int) -> PackedVector2Array:
	var corners := PackedVector2Array()

	for i in range(sides):
		var a = TAU * i / sides - PI / 2.0
		corners.append(center + Vector2(cos(a), sin(a)) * radius)

	return _densify(corners)


func _star(center: Vector2, outer_r: float, inner_r: float, points: int) -> PackedVector2Array:
	var corners := PackedVector2Array()

	for i in range(points * 2):
		var r = outer_r if i % 2 == 0 else inner_r
		var a = TAU * i / (points * 2) - PI / 2.0

		corners.append(center + Vector2(cos(a), sin(a)) * r)

	return _densify(corners)


func _umbrella(center: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()

	for i in range(40):
		var a = lerp(PI, TAU, i / 39.0)
		pts.append(center + Vector2(cos(a), sin(a)) * 140)

	pts.append(center + Vector2(0, 170))
	pts.append(center + Vector2(25, 210))
	pts.append(center + Vector2(0, 240))
	pts.append(center + Vector2(-25, 210))
	pts.append(center + Vector2(0, 170))

	return _densify(pts)


func _densify(corners: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array()

	for i in range(corners.size()):
		var a = corners[i]
		var b = corners[(i + 1) % corners.size()]

		var dist = a.distance_to(b)
		var steps = max(1, int(dist / POINT_SPACING))

		for j in range(steps):
			result.append(a.lerp(b, float(j) / steps))

	return result


func _on_draw():
	if shape_points.size() < 2:
		return

	for i in range(shape_points.size()):
		var a = shape_points[i]
		var b = shape_points[(i + 1) % shape_points.size()]

		draw_control.draw_line(a, b, Color.WHITE, 3)

	for i in range(shape_points.size()):
		if traced[i]:
			draw_control.draw_circle(shape_points[i], 5, Color.GREEN)

	if not game_over:
		draw_control.draw_circle(
			get_viewport().get_mouse_position(),
			8,
			Color.RED
		)
func curve_to_points(curve: Curve2D) -> PackedVector2Array:
	var pts := PackedVector2Array()

	var length = curve.get_baked_length()

	var d = 0.0

	while d < length:
		pts.append(curve.sample_baked(d))
		d += POINT_SPACING

	return pts

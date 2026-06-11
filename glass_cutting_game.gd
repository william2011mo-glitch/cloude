extends CanvasLayer

signal game_finished(won: bool, score: int)

const TOLERANCE := 20.0
const POINT_SPACING := 8.0

var shape_points: PackedVector2Array = []
var traced := []
var game_over := false
var won := false

var draw_control: Control
var status_label: Label
var _start_panel: Control
var _state: String = "start"


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

	# ── Start panel ──
	var vp := get_viewport().get_visible_rect().size
	_start_panel = Control.new()
	_start_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_start_panel)

	var sp_bg := ColorRect.new()
	sp_bg.color = Color(0, 0, 0, 0.82)
	sp_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sp_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_panel.add_child(sp_bg)

	var sp_box := VBoxContainer.new()
	sp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_box.add_theme_constant_override("separation", 22)
	sp_box.position = Vector2(vp.x / 2.0 - 300.0, vp.y / 2.0 - 150.0)
	sp_box.custom_minimum_size = Vector2(600, 0)

	var sp_title := Label.new()
	sp_title.text = "Glass Cutting"
	sp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_title.add_theme_font_size_override("font_size", 58)
	sp_box.add_child(sp_title)

	var sp_sub := Label.new()
	sp_sub.text = "Press Space to start"
	sp_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_sub.add_theme_font_size_override("font_size", 28)
	sp_sub.modulate = Color(0.78, 0.78, 0.78)
	sp_box.add_child(sp_sub)

	var sp_how := Label.new()
	sp_how.text = "Hold the mouse button and trace the glowing shape.\nStray too far from the line and the glass cracks."
	sp_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_how.add_theme_font_size_override("font_size", 21)
	sp_how.modulate = Color(0.60, 0.60, 0.60)
	sp_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_how.custom_minimum_size = Vector2(600, 0)
	sp_box.add_child(sp_how)

	sp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta):
	draw_control.queue_redraw()

	if game_over or _state != "playing":
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
			status_label.text = "FAILED"
			emit_signal("game_finished", false, 0)
			_show_end_overlay(false)
			return

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
			status_label.text = "YOU WIN!"
			emit_signal("game_finished", true, 1)
			_show_end_overlay(true)
			return
	if Input.is_key_pressed(KEY_R):
		_restart()


func _show_end_overlay(win: bool) -> void:
	var vp := get_viewport().get_visible_rect().size
	var ep := Control.new()
	ep.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ep)

	var ep_bg := ColorRect.new()
	ep_bg.color = Color(0, 0, 0, 0.70)
	ep_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ep_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ep.add_child(ep_bg)

	var ep_lbl := Label.new()
	ep_lbl.text = "Glass cut perfectly!\nYou've stolen the vase." if win else "Glass cracked.\nBetter luck next time."
	ep_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ep_lbl.add_theme_font_size_override("font_size", 52)
	ep_lbl.add_theme_color_override("font_color", Color(0.20, 0.95, 0.44) if win else Color(0.95, 0.20, 0.20))
	ep_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ep_lbl.custom_minimum_size = Vector2(700, 0)
	ep_lbl.position = Vector2(vp.x / 2.0 - 350.0, vp.y / 2.0 - 80.0)
	ep.add_child(ep_lbl)

	await get_tree().create_timer(2.5).timeout
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if _state == "start" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_start_panel.visible = false
		_state = "playing"
		get_viewport().set_input_as_handled()

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

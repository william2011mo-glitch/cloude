extends CanvasLayer

signal game_finished(won: bool, score: int)

# ── Constants ──────────────────────────────────────────────────────────────────
const MAX_GUESSES   := 6
const SLOTS         := 3   # colors per guess

const PALETTE := {
	"white":   Color(1.00, 1.00, 1.00),
	"cream":   Color(1.00, 1.00, 0.80),
	"yellow":  Color(1.00, 0.85, 0.00),
	"orange":  Color(1.00, 0.55, 0.00),
	"brown":   Color(0.65, 0.40, 0.10),
	"hotpink": Color(1.00, 0.20, 0.50),
	"red":     Color(0.80, 0.10, 0.10),
	"cyan":    Color(0.00, 0.85, 0.90),
	"mint":    Color(0.50, 1.00, 0.60),
	"lime":    Color(0.70, 1.00, 0.00),
	"green":   Color(0.10, 0.75, 0.20),
	"olive":   Color(0.50, 0.55, 0.00),
	"teal":    Color(0.00, 0.65, 0.55),
	"pink":    Color(1.00, 0.70, 0.75),
	"lavender":Color(0.80, 0.65, 1.00),
	"magenta": Color(0.90, 0.00, 0.90),
	"purple":  Color(0.50, 0.00, 0.75),
	"blue":    Color(0.25, 0.45, 0.95),
	"navy":    Color(0.10, 0.10, 0.60),
	"black":   Color(0.05, 0.05, 0.05),
}

const PALETTE_KEYS := [
	"white","cream","yellow","orange","brown","hotpink","red",
	"cyan","mint","lime","green","olive","teal",
	"pink","lavender","magenta","purple","blue","navy","black"
]

# How the palette is laid out in rows (matches the screenshot layout)
const PALETTE_ROWS := [
	["white","cream","yellow","orange","brown","hotpink","red"],
	["cyan","mint","lime","green","olive","teal"],
	["pink","lavender","magenta","purple","blue","navy","black"],
]

# ── Layout ─────────────────────────────────────────────────────────────────────
const SWATCH_SIZE   := 64
const SWATCH_GAP    := 6
const SLOT_SIZE     := 70
const SLOT_GAP      := 8
const RESULT_R      := 30   # radius of result circle
const PIE_R         := 90

# ── State ──────────────────────────────────────────────────────────────────────
var target_colors : Array  # 3 color keys, the answer
var target_weights: Array  # 3 floats summing to 1.0

var current_slot  : int = 0          # which of the 3 slots is being filled
var current_guess : Array = []       # up to 3 color keys
var guess_history : Array = []       # array of {colors, weights, result_color, accuracy, feedback}
var game_over     : bool  = false

# UI refs
var _control          : Control
var _pie_node         : Control   # draws the pie chart
var _grid_rows        : Array = [] # array of {slots: [ColorRect x3], result: ColorRect}
var _palette_swatches : Dictionary = {}  # key → ColorRect
var _msg_label        : Label
var _enter_btn        : Button
var _del_btn          : Button
var _start_panel      : Control
var _state            : String = "start"

# ── Entry ──────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_pick_target()
	_build_ui()
	_refresh_grid()
	_refresh_palette()
	_start_panel.visible = true

# ── Target selection ───────────────────────────────────────────────────────────
func _pick_target() -> void:
	var keys = PALETTE_KEYS.duplicate()
	keys.shuffle()
	target_colors = keys.slice(0, 3)

	# Random weights that sum to 1, each at least 0.15, snapped to 0.05
	var w = _random_weights(3)
	target_weights = w

func _random_weights(n: int) -> Array:
	# Generate n floats >= 0.15 summing to 1, rounded to nearest 0.05
	var w: Array = []
	var remaining := 1.0
	for i in range(n):
		if i == n - 1:
			w.append(snappedf(remaining, 0.05))
		else:
			var lo: float = 0.15
			var hi: float = remaining - lo * (n - 1 - i)
			var v: float = snappedf(randf_range(lo, hi), 0.05)
			v = clampf(v, lo, hi)
			w.append(v)
			remaining -= v
	return w

# ── UI Build ───────────────────────────────────────────────────────────────────
func _build_ui() -> void:
	_control = Control.new()
	_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_control)

	# Dark background
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.17)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_control.add_child(bg)

	var vp := get_viewport().get_visible_rect().size
	var cx := vp.x / 2.0

	# ── Pie chart ──
	_pie_node = Control.new()
	_pie_node.position = Vector2(cx - PIE_R, 30)
	_pie_node.custom_minimum_size = Vector2(PIE_R * 2, PIE_R * 2)
	_pie_node.connect("draw", _draw_pie.bind(_pie_node))
	_control.add_child(_pie_node)

	# ── Guess grid ──
	var grid_top: int = 30 + PIE_R * 2 + 20
	var grid_w: int = SLOTS * (SLOT_SIZE + SLOT_GAP) - SLOT_GAP + SLOT_GAP + RESULT_R * 2
	var grid_x: float = cx - grid_w / 2.0

	for row in range(MAX_GUESSES):
		var row_y: float = grid_top + row * (SLOT_SIZE + SLOT_GAP)
		var slots_arr : Array = []

		for col in range(SLOTS):
			var cr := ColorRect.new()
			cr.size = Vector2(SLOT_SIZE, SLOT_SIZE)
			cr.position = Vector2(grid_x + col * (SLOT_SIZE + SLOT_GAP), row_y)
			cr.color = Color(0.30, 0.30, 0.32)
			_control.add_child(cr)
			slots_arr.append(cr)

		# Result circle (drawn as a Panel with circular Label overlay)
		var res_bg := ColorRect.new()
		res_bg.size = Vector2(RESULT_R * 2, RESULT_R * 2)
		res_bg.position = Vector2(
			grid_x + SLOTS * (SLOT_SIZE + SLOT_GAP) + 4,
			row_y + SLOT_SIZE / 2.0 - RESULT_R
		)
		res_bg.color = Color(0.25, 0.25, 0.27)
		_control.add_child(res_bg)

		var res_lbl := Label.new()
		res_lbl.size = res_bg.size
		res_lbl.position = res_bg.position
		res_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		res_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		res_lbl.text = "?"
		res_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		_control.add_child(res_lbl)

		_grid_rows.append({"slots": slots_arr, "result_bg": res_bg, "result_lbl": res_lbl})

	# ── Palette ──
	var pal_top: int = grid_top + MAX_GUESSES * (SLOT_SIZE + SLOT_GAP) + 16
	var row_y: float = float(pal_top)

	for pal_row in PALETTE_ROWS:
		var pal_row_width: int = pal_row.size() * (SWATCH_SIZE + SWATCH_GAP) - SWATCH_GAP
		var pal_row_x: float = cx - pal_row_width / 2.0
		for i in range(pal_row.size()):
			var key : String = pal_row[i]
			var sw := ColorRect.new()
			sw.size     = Vector2(SWATCH_SIZE, SWATCH_SIZE)
			sw.position = Vector2(pal_row_x + i * (SWATCH_SIZE + SWATCH_GAP), row_y)
			sw.color    = PALETTE[key]
			sw.mouse_filter = Control.MOUSE_FILTER_STOP
			sw.connect("gui_input", _on_swatch_input.bind(key))
			_control.add_child(sw)
			_palette_swatches[key] = sw
		row_y += SWATCH_SIZE + SWATCH_GAP

	# ── Buttons ──
	var btn_y: float = row_y + 4

	_del_btn = Button.new()
	_del_btn.text = "Delete"
	_del_btn.size = Vector2(100, 44)
	_del_btn.position = Vector2(cx - 110, btn_y)
	_del_btn.connect("pressed", _on_delete)
	_control.add_child(_del_btn)

	_enter_btn = Button.new()
	_enter_btn.text = "ENTER"
	_enter_btn.size = Vector2(100, 44)
	_enter_btn.position = Vector2(cx + 10, btn_y)
	_enter_btn.connect("pressed", _on_enter)
	_control.add_child(_enter_btn)

	# ── Target color display (shown to the side) ──
	var target_mixed: Color = _mix_colors(target_colors, target_weights)
	var target_x: float = cx + grid_w / 2.0 + 60.0
	var target_y: float = float(grid_top)

	var target_title := Label.new()
	target_title.text = "Target"
	target_title.position = Vector2(target_x, target_y)
	target_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_control.add_child(target_title)

	var target_swatch := ColorRect.new()
	target_swatch.size = Vector2(80, 80)
	target_swatch.position = Vector2(target_x, target_y + 24)
	target_swatch.color = target_mixed
	_control.add_child(target_swatch)

	# ── Message label ──
	_msg_label = Label.new()
	_msg_label.size = Vector2(500, 32)
	_msg_label.position = Vector2(cx - 250, btn_y + 52)
	_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_msg_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_control.add_child(_msg_label)

	# ── Start / instructions panel ──
	_start_panel = Control.new()
	_start_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_start_panel.visible = false
	_control.add_child(_start_panel)

	var sp_bg := ColorRect.new()
	sp_bg.color = Color(0, 0, 0, 0.82)
	sp_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sp_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_panel.add_child(sp_bg)

	var sp_box := VBoxContainer.new()
	sp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_box.add_theme_constant_override("separation", 22)
	sp_box.position = Vector2(cx - 300.0, vp.y / 2.0 - 160.0)
	sp_box.custom_minimum_size = Vector2(600, 0)
	_start_panel.add_child(sp_box)

	var sp_title := Label.new()
	sp_title.text = "Color Matching"
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
	sp_how.text = "Pick 3 colors from the palette to mix and match the target color.\nGet above 90% accuracy within 6 guesses to steal the painting."
	sp_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_how.add_theme_font_size_override("font_size", 21)
	sp_how.modulate = Color(0.60, 0.60, 0.60)
	sp_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_how.custom_minimum_size = Vector2(600, 0)
	sp_box.add_child(sp_how)

	sp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ── Input ──────────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if _state == "start" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_start_panel.visible = false
		_state = "playing"
		get_viewport().set_input_as_handled()

func _on_swatch_input(event: InputEvent, key: String) -> void:
	if game_over or _state != "playing":
		return
	if not (event is InputEventMouseButton):
		return
	if not (event as InputEventMouseButton).pressed:
		return
	if current_guess.size() >= SLOTS:
		return
	current_guess.append(key)
	_refresh_grid()

func _on_delete() -> void:
	if game_over or _state != "playing" or current_guess.is_empty():
		return
	current_guess.pop_back()
	_refresh_grid()

func _on_enter() -> void:
	if game_over or _state != "playing":
		return
	if current_guess.size() < SLOTS:
		_msg_label.text = "Pick 3 colors first."
		return
	_msg_label.text = ""
	_submit_guess()

# ── Guess logic ────────────────────────────────────────────────────────────────
func _submit_guess() -> void:
	var row_idx: int = guess_history.size()

	# Build equal weights for the guess (each color = 1/3)
	var guess_weights: Array = [1.0/3.0, 1.0/3.0, 1.0/3.0]

	# Mix guessed color
	var mixed_guess: Color = _mix_colors(current_guess, guess_weights)
	# Mix target color
	var mixed_target: Color = _mix_colors(target_colors, target_weights)

	# Accuracy = 1 - average channel distance (0..1 → 0..100%)
	var accuracy: float = _color_accuracy(mixed_guess, mixed_target)

	# Per-slot feedback
	# Green = correct color in correct slot
	# Yellow = correct color in wrong slot
	# Gray = color not in target at all
	var feedback: Array = _compute_feedback(current_guess)

	guess_history.append({
		"colors":        current_guess.duplicate(),
		"result_color":  mixed_guess,
		"accuracy":      accuracy,
		"feedback":      feedback
	})

	current_guess = []
	_refresh_grid()
	_pie_node.queue_redraw()

	if accuracy >= 0.90:
		game_over = true
		_end_game(true)
	elif row_idx + 1 >= MAX_GUESSES:
		game_over = true
		_end_game(false)

func _end_game(won: bool) -> void:
	var ep := Control.new()
	ep.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_control.add_child(ep)

	var ep_bg := ColorRect.new()
	ep_bg.color = Color(0, 0, 0, 0.72)
	ep_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ep_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ep.add_child(ep_bg)

	var vp := get_viewport().get_visible_rect().size
	var ep_lbl := Label.new()
	ep_lbl.text = "Color matched!\nYou've stolen the painting." if won else "Out of guesses.\nBetter luck next time."
	ep_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ep_lbl.add_theme_font_size_override("font_size", 52)
	ep_lbl.add_theme_color_override("font_color", Color(0.20, 0.95, 0.44) if won else Color(0.95, 0.20, 0.20))
	ep_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ep_lbl.custom_minimum_size = Vector2(700, 0)
	ep_lbl.position = Vector2(vp.x / 2.0 - 350.0, vp.y / 2.0 - 80.0)
	ep.add_child(ep_lbl)

	emit_signal("game_finished", won, guess_history.size())
	await get_tree().create_timer(2.5).timeout
	queue_free()

func _compute_feedback(guess: Array) -> Array:
	# Returns array of "green", "yellow", or "gray" per slot
	var result: Array = []
	var target_remaining: Array = target_colors.duplicate()

	# First pass: greens
	var used: Array = [false, false, false]
	for i in range(SLOTS):
		if guess[i] == target_colors[i]:
			result.append("green")
			used[i] = true
			target_remaining[i] = ""
		else:
			result.append("gray")

	# Second pass: yellows
	for i in range(SLOTS):
		if result[i] == "green":
			continue
		for j in range(SLOTS):
			if not used[j] and target_remaining[j] == guess[i]:
				result[i] = "yellow"
				used[j] = true
				target_remaining[j] = ""
				break

	return result

func _mix_colors(keys: Array, weights: Array) -> Color:
	var r := 0.0; var g := 0.0; var b := 0.0
	for i in range(keys.size()):
		var c : Color = PALETTE[keys[i]]
		r += c.r * weights[i]
		g += c.g * weights[i]
		b += c.b * weights[i]
	return Color(r, g, b)

func _color_accuracy(a: Color, b: Color) -> float:
	var channel_dist: float = (abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b)) / 3.0
	return clampf(1.0 - channel_dist, 0.0, 1.0)

# ── Refresh UI ─────────────────────────────────────────────────────────────────
func _refresh_grid() -> void:
	for row_idx in range(MAX_GUESSES):
		var row = _grid_rows[row_idx]

		if row_idx < guess_history.size():
			# Submitted guess
			var hist = guess_history[row_idx]
			for col in range(SLOTS):
				var cr : ColorRect = row["slots"][col]
				cr.color = PALETTE[hist["colors"][col]]
				# Feedback border via modulate trick: overlay a thin border child
				_set_slot_border(cr, hist["feedback"][col])

			var acc_pct: int = int(hist["accuracy"] * 100)
			var res_c: Color = hist["result_color"]
			row["result_bg"].color = res_c
			row["result_lbl"].text = "%d%%" % acc_pct
			# Pick white or black label based on brightness
			var bright: float = res_c.r * 0.299 + res_c.g * 0.587 + res_c.b * 0.114
			var lbl_col: Color = Color.BLACK if bright > 0.55 else Color.WHITE
			row["result_lbl"].add_theme_color_override("font_color", lbl_col)

		elif row_idx == guess_history.size():
			# Active row
			for col in range(SLOTS):
				var cr : ColorRect = row["slots"][col]
				if col < current_guess.size():
					cr.color = PALETTE[current_guess[col]]
					_set_slot_border(cr, "active")
				else:
					cr.color = Color(0.30, 0.30, 0.32)
					_set_slot_border(cr, "none")
			row["result_bg"].color = Color(0.25, 0.25, 0.27)
			row["result_lbl"].text = "?"
			row["result_lbl"].add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))

		else:
			# Future rows
			for col in range(SLOTS):
				var cr : ColorRect = row["slots"][col]
				cr.color = Color(0.30, 0.30, 0.32)
				_set_slot_border(cr, "none")
			row["result_bg"].color = Color(0.25, 0.25, 0.27)
			row["result_lbl"].text = "?"
			row["result_lbl"].add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))

func _set_slot_border(cr: ColorRect, feedback: String) -> void:
	# Remove old border child
	for c in cr.get_children():
		c.queue_free()
	var border_color : Color
	match feedback:
		"green":  border_color = Color(0.20, 0.80, 0.20)
		"yellow": border_color = Color(0.90, 0.80, 0.10)
		"active": border_color = Color(0.70, 0.70, 0.70)
		_:        return  # no border

	var T: int = 4  # border thickness px
	var s: int = int(SLOT_SIZE)
	for rect in [
		Rect2(0,     0,      s,     T),
		Rect2(0,     s - T,  s,     T),
		Rect2(0,     0,      T,     s),
		Rect2(s - T, 0,      T,     s),
	]:
		var bar := ColorRect.new()
		bar.position = rect.position
		bar.size     = rect.size
		bar.color    = border_color
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cr.add_child(bar)

func _refresh_palette() -> void:
	pass  # palette is static; could dim used colors here if desired

# ── Pie chart draw ─────────────────────────────────────────────────────────────
func _draw_pie(node: Control) -> void:
	var cx := float(PIE_R)
	var cy := float(PIE_R)
	var r  := float(PIE_R)

	if guess_history.is_empty():
		# Draw empty pie with target slice outlines as placeholder
		node.draw_circle(Vector2(cx, cy), r, Color(0.35, 0.35, 0.37))
		# Draw divider lines for 3 equal slices so player knows structure
		var angle: float = -PI / 2.0
		var step: float = TAU / 3.0
		for i in range(3):
			var ex: float = cx + cos(angle + i * step) * r
			var ey: float = cy + sin(angle + i * step) * r
			node.draw_line(Vector2(cx, cy), Vector2(ex, ey), Color(0.1, 0.1, 0.1), 2.0)
		return

	# Show the last submitted guess's pie
	var last = guess_history[-1]
	var colors : Array = last["colors"]
	var weights: Array = [1.0/3.0, 1.0/3.0, 1.0/3.0]

	var start_angle: float = -PI / 2.0
	for i in range(SLOTS):
		var slice_angle: float = TAU * float(weights[i])
		var pts := PackedVector2Array()
		pts.append(Vector2(cx, cy))
		var num_points: int = max(2, int(slice_angle / 0.05))
		for p in range(num_points + 1):
			var point_angle: float = start_angle + slice_angle * p / num_points
			pts.append(Vector2(cx + cos(point_angle) * r, cy + sin(point_angle) * r))
		node.draw_colored_polygon(pts, PALETTE[colors[i]])
		node.draw_line(Vector2(cx, cy),
			Vector2(cx + cos(start_angle) * r, cy + sin(start_angle) * r),
			Color(0.05, 0.05, 0.05), 2.0)
		start_angle += slice_angle

	# Outline
	node.draw_arc(Vector2(cx, cy), r, 0, TAU, 64, Color(0.05, 0.05, 0.05), 2.0)

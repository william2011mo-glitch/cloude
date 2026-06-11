extends CanvasLayer

signal game_finished(won: bool, score: int)

const SW       := 1920.0
const SH       := 1080.0
const GRAVITY  := 1800.0
const BOUNCE   := -920.0
const SPEED    := 550.0
const SCROLL   := 38.0
const PW       := 48.0
const PH       := 48.0
const PLATW    := 160.0
const PLATH    := 16.0
const TARGET   := 25

const C_BG           := Color(0.05, 0.05, 0.12)
const C_GREEN        := Color(0.18, 0.88, 0.28)
const C_YELLOW       := Color(1.00, 0.88, 0.10)
const C_YELLOW_CRACK := Color(0.70, 0.62, 0.07)
const C_RED          := Color(0.94, 0.17, 0.17)
const C_PLAYER       := Color(0.35, 0.55, 1.00)

var state  := "start"
var px     := SW * 0.5
var py     := SH * 0.65
var pvx    := 0.0
var pvy    := 0.0
var score  := 0
var platforms: Array = []
var shards: Array    = []
var _ctrl: Control

func _ready() -> void:
	layer = 15
	_ctrl = Control.new()
	_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_ctrl)
	_ctrl.draw.connect(_on_draw)
	_ctrl.gui_input.connect(_on_click)

# ── game init ──────────────────────────────────────────────────────────────
func _new_game() -> void:
	px = SW * 0.5
	py = SH * 0.65
	pvx = 0.0
	pvy = 0.0
	score = 0
	platforms.clear()
	shards.clear()
	_seed_platforms()

func _seed_platforms() -> void:
	var y := SH * 0.80
	for i in range(20):
		var type := _rand_type(i < 5)
		_spawn_row(y, type)
		y -= randf_range(60.0, 85.0)

func _rand_type(_force_safe: bool) -> int:
	return 2  # always red

func _spawn_row(y: float, type: int) -> void:
	var count := 1 + randi() % 2  # 1 or 2 platforms per row
	var slot := SW / count
	for i in range(count):
		var x := slot * i + randf_range(PLATW / 2.0, slot - PLATW / 2.0)
		x = clampf(x, PLATW / 2.0, SW - PLATW / 2.0)
		_add_plat(x, y, type)

func _add_plat(x: float, y: float, type: int) -> void:
	platforms.append({"x": x, "y": y, "type": type,
		"hits": 0, "active": true, "scored": false})

# ── main loop ──────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	_ctrl.queue_redraw()
	if state != "playing":
		return

	# Input
	pvx = 0.0
	if Input.is_key_pressed(KEY_LEFT)  or Input.is_key_pressed(KEY_A): pvx = -SPEED
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): pvx =  SPEED

	# Physics
	pvy += GRAVITY * delta
	var prev_py := py
	px += pvx * delta
	py += pvy * delta

	# Wrap X
	if   px < -PW / 2:   px = SW + PW / 2
	elif px > SW + PW / 2: px = -PW / 2

	# Camera: push everything down when player climbs above 40% mark
	if py < SH * 0.40:
		var shift := SH * 0.40 - py
		py = SH * 0.40
		for p in platforms: p.y += shift
		for s in shards:    s.y += shift

	# Constant upward world scroll
	for p in platforms: p.y += SCROLL * delta
	for s in shards:    s.y += SCROLL * delta

	# Collision (only while falling)
	if pvy > 0:
		var pb: float = py
		var pl: float = px - PW / 2.0
		var pr: float = px + PW / 2.0
		for p in platforms:
			if not p.active: continue
			var ql: float = p.x - PLATW / 2.0
			var qr: float = p.x + PLATW / 2.0
			var pt: float = p.y
			if pr > ql and pl < qr and pb >= pt and prev_py <= pt + PLATH:
				py  = p.y
				pvy = BOUNCE
				_land(p)
				break

	# Spawn rows above top of screen
	var top_y: float = INF
	for p in platforms:
		if p.active and p.y < top_y: top_y = p.y
	while top_y > -80:
		var ny := top_y - randf_range(60.0, 85.0)
		_spawn_row(ny, _rand_type(false))
		top_y = ny

	# Cleanup
	platforms = platforms.filter(func(p): return p.y < SH + 100.0)
	shards    = shards.filter(func(s): return s.y < SH + 120.0 and s.life > 0.0)

	# Update shards
	for s in shards:
		s.vy += 700.0 * delta
		s.x  += s.vx * delta
		s.y  += s.vy * delta
		s.life -= delta

	# Lose — show message briefly then close
	if py > SH + 100.0 and state == "playing":
		state = "gameover"
		emit_signal("game_finished", false, score)
		await get_tree().create_timer(2.5).timeout
		queue_free()

	# Win
	if score >= TARGET and state == "playing":
		state = "win"
		emit_signal("game_finished", true, score)
		await get_tree().create_timer(2.5).timeout
		queue_free()

# ── landing logic ──────────────────────────────────────────────────────────
func _land(p: Dictionary) -> void:
	match p.type:
		0:  # Green — safe forever
			if not p.scored: p.scored = true; score += 1
		1:  # Yellow — cracks then breaks
			if not p.scored: p.scored = true; score += 1
			p.hits += 1
			if p.hits >= 2: _break(p)
		2:  # Red — instant break
			if not p.scored: p.scored = true; score += 1
			_break(p)

func _break(p: Dictionary) -> void:
	p.active = false
	var col := C_RED if p.type == 2 else C_YELLOW
	for i in range(10):
		shards.append({
			"x":    p.x + randf_range(-PLATW / 2.0, PLATW / 2.0),
			"y":    p.y,
			"vx":   randf_range(-260.0, 260.0),
			"vy":   randf_range(-420.0, 0.0),
			"life": randf_range(0.35, 0.80),
			"color": col,
			"size": randf_range(5.0, 13.0),
		})

# ── input ──────────────────────────────────────────────────────────────────
func _on_click(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if state == "start":
			state = "playing"
			_new_game()
			pvy = BOUNCE

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		var won := (state == "win")
		emit_signal("game_finished", won, score)
		queue_free()

# ── drawing ────────────────────────────────────────────────────────────────
func _on_draw() -> void:
	var font := ThemeDB.fallback_font
	_ctrl.draw_rect(Rect2(0, 0, SW, SH), C_BG)

	if state == "start":
		_dc(font, "Glass Platform Heist", SH * 0.40, 82, Color.WHITE)
		_dc(font, "Space to start  •  Land on %d platforms to win" % TARGET, SH * 0.52, 34, Color(0.7, 0.7, 0.7))
		_dc(font, "A / D  or  ← →  to move", SH * 0.60, 30, Color(0.5, 0.5, 0.5))
		return

	# Platforms
	for p in platforms:
		if not p.active: continue
		var col: Color
		match p.type:
			0: col = C_GREEN
			1: col = C_YELLOW_CRACK if p.hits > 0 else C_YELLOW
			2: col = C_RED
			_: col = C_GREEN
		var rx: float = p.x - PLATW / 2.0
		var ry: float = p.y
		_ctrl.draw_rect(Rect2(rx, ry, PLATW, PLATH), col)
		_ctrl.draw_rect(Rect2(rx + 5, ry + 3, PLATW - 10, 4), Color(1, 1, 1, 0.22))

	# Shards
	for s in shards:
		var a := clampf(s.life * 2.5, 0.0, 1.0)
		_ctrl.draw_rect(Rect2(s.x, s.y, s.size, s.size),
			Color(s.color.r, s.color.g, s.color.b, a))

	# Player
	_ctrl.draw_rect(Rect2(px - PW / 2.0, py - PH, PW, PH), C_PLAYER)
	_ctrl.draw_rect(Rect2(px - PW / 2.0 + 5, py - PH + 5, PW - 10, 10),
		Color(0.6, 0.78, 1.0, 0.38))

	# HUD
	_ctrl.draw_string(font, Vector2(28, 52),
		"Platforms: %d / %d" % [score, TARGET],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color.WHITE)
	_ctrl.draw_string(font, Vector2(28, SH - 22),
		"Esc = quit",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.44, 0.44, 0.44))

	if state == "gameover":
		_ctrl.draw_rect(Rect2(0, 0, SW, SH), Color(0, 0, 0, 0.55))
		_dc(font, "GAME OVER", SH * 0.43, 90, Color(0.95, 0.20, 0.20))
		_dc(font, "Better luck next time...", SH * 0.56, 36, Color.WHITE)
	elif state == "win":
		_ctrl.draw_rect(Rect2(0, 0, SW, SH), Color(0, 0, 0, 0.55))
		_dc(font, "YOU WIN!", SH * 0.43, 90, Color(0.20, 0.95, 0.44))
		_dc(font, "Esc to continue", SH * 0.56, 36, Color.WHITE)

func _dc(font: Font, text: String, y: float, size: int, color: Color) -> void:
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	_ctrl.draw_string(font, Vector2(SW / 2.0 - tw / 2.0, y),
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw_legend(font: Font) -> void:
	var items := [
		[C_GREEN,  "Green  — safe, never breaks"],
		[C_YELLOW, "Yellow — cracks on first hit, breaks on second"],
		[C_RED,    "Red    — breaks the instant you land"],
	]
	var base_y := SH * 0.74
	for i in items.size():
		_ctrl.draw_rect(Rect2(SW / 2.0 - 260, base_y + i * 52 - 20, 44, 16), items[i][0])
		_ctrl.draw_string(font, Vector2(SW / 2.0 - 205, base_y + i * 52),
			items[i][1], HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)

extends CanvasLayer
## "Plate Stacker" — stack porcelain plates as high as you can without
## knocking the tower over. Stack enough of them in a row and the
## clatter is loud enough to mask you slipping the diamond out of the pot.

signal game_finished(won: bool, score: int)

const PLATE_HEIGHT := 20.0
const INITIAL_WIDTH := 200.0
const PERFECT_MARGIN := 4.0
const SPAWN_GAP := 220.0
const BASE_SPEED := 220.0
const SPEED_INCREMENT := 16.0
const DROP_SPEED := 900.0
const FALL_GRAVITY := 1700.0
const WIN_SCORE := 10

enum State { START, MOVING, DROPPING, GAME_OVER, WIN }

var pastel_palette := [
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
	Color(0.0, 0.0, 0.0, 1.0),
]

var screen_size: Vector2
var lane_center_x: float
var play_left: float
var play_right: float
var table_screen_y: float

var world: Node2D
var plates_layer: Node2D
var moving_plate: ColorRect
var score_label: Label
var hint_label: Label
var start_panel: Control
var end_panel: ColorRect
var end_label: Label
var restart_button: Button
var secondary_button: Button

var state: int = State.START
var score: int = 0
var speed: float = BASE_SPEED
var direction: int = 1
var stack_count: int = 0

var current_top_x: float
var current_top_width: float
var current_max_width: float = INITIAL_WIDTH

var moving_x: float
var moving_width: float
var moving_local_y: float
var moving_color: Color


func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	lane_center_x = screen_size.x / 2.0
	play_left = lane_center_x - 260.0
	play_right = lane_center_x + 260.0
	table_screen_y = screen_size.y - 180.0

	_build_ui()
	state = State.START
	start_panel.visible = true


# ─── UI construction ──────────────────────────────────────────────────────────

func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.12, 0.09, 0.1, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.982, 0.965, 0.941, 1.0)
	backdrop.size = Vector2(640, screen_size.y - 80)
	backdrop.position = Vector2(lane_center_x - 320, 40)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	world = Node2D.new()
	world.position = Vector2(0, table_screen_y)
	add_child(world)

	plates_layer = Node2D.new()
	world.add_child(plates_layer)

	var table := ColorRect.new()
	table.color = Color(0.254, 0.168, 0.12, 1.0)
	table.size = Vector2(640, 26)
	table.position = Vector2(lane_center_x - 320, 0)
	world.add_child(table)

	score_label = Label.new()
	score_label.text = "Plates stacked: 0"
	score_label.add_theme_font_size_override("font_size", 30)
	score_label.position = Vector2(lane_center_x - 150, 28)
	add_child(score_label)

	hint_label = Label.new()
	hint_label.text = "Click or press Space to drop the plate — stack %d in a row to win" % WIN_SCORE
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.modulate = Color(1, 1, 1, 0.85)
	hint_label.position = Vector2(lane_center_x - 250, 70)
	add_child(hint_label)

	# ── Start / instructions overlay ──────────────────────────────────────────
	start_panel = Control.new()
	start_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	start_panel.visible = false
	add_child(start_panel)

	var sp_bg := ColorRect.new()
	sp_bg.color = Color(0, 0, 0, 0.72)
	sp_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	sp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_panel.add_child(sp_bg)

	var sp_box := VBoxContainer.new()
	sp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_box.add_theme_constant_override("separation", 18)
	sp_box.position = Vector2(lane_center_x - 240, screen_size.y / 2.0 - 130)
	sp_box.custom_minimum_size = Vector2(480, 0)
	start_panel.add_child(sp_box)

	var sp_title := Label.new()
	sp_title.text = "Plate Stacker"
	sp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_title.add_theme_font_size_override("font_size", 60)
	sp_box.add_child(sp_title)

	var sp_sub := Label.new()
	sp_sub.text = "Space to start  •  Stack %d plates to win" % WIN_SCORE
	sp_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_sub.add_theme_font_size_override("font_size", 26)
	sp_sub.modulate = Color(0.85, 0.85, 0.85)
	sp_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_sub.custom_minimum_size = Vector2(480, 0)
	sp_box.add_child(sp_sub)

	var sp_how := Label.new()
	sp_how.text = "A sliding plate swings back and forth above the stack.\nClick (or press Space) to drop it — try to line it up\nas closely as possible. Miss the stack and it's over."
	sp_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_how.add_theme_font_size_override("font_size", 20)
	sp_how.modulate = Color(0.65, 0.65, 0.65)
	sp_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_how.custom_minimum_size = Vector2(480, 0)
	sp_box.add_child(sp_how)

	# ── End overlay ────────────────────────────────────────────────────────────
	end_panel = ColorRect.new()
	end_panel.color = Color(0, 0, 0, 0.72)
	end_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_panel.visible = false
	add_child(end_panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	box.position = Vector2(lane_center_x - 170, screen_size.y / 2.0 - 110)
	box.custom_minimum_size = Vector2(340, 0)
	end_panel.add_child(box)

	end_label = Label.new()
	end_label.add_theme_font_size_override("font_size", 28)
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.custom_minimum_size = Vector2(340, 0)
	end_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(end_label)

	restart_button = Button.new()
	restart_button.text = "Try Again"
	restart_button.custom_minimum_size = Vector2(180, 46)
	restart_button.add_theme_font_size_override("font_size", 18)
	restart_button.pressed.connect(_on_restart_pressed)
	box.add_child(restart_button)

	secondary_button = Button.new()
	secondary_button.text = "Walk Away"
	secondary_button.custom_minimum_size = Vector2(180, 46)
	secondary_button.add_theme_font_size_override("font_size", 18)
	secondary_button.pressed.connect(_on_secondary_pressed)
	box.add_child(secondary_button)


# ─── Game flow ────────────────────────────────────────────────────────────────

func _start_game() -> void:
	for c in plates_layer.get_children():
		c.queue_free()
	if moving_plate and is_instance_valid(moving_plate):
		moving_plate.queue_free()
		moving_plate = null

	world.position = Vector2(0, table_screen_y)
	state = State.MOVING
	score = 0
	speed = BASE_SPEED
	direction = 1
	stack_count = 0
	current_max_width = INITIAL_WIDTH
	end_panel.visible = false
	score_label.text = "Plates stacked: 0"
	restart_button.visible = true
	secondary_button.text = "Walk Away"

	current_top_x = lane_center_x - INITIAL_WIDTH / 2.0
	current_top_width = INITIAL_WIDTH
	_add_plate_visual(current_top_x, stack_count, current_top_width, Color.BLACK)
	stack_count += 1

	_spawn_moving_plate()


func _plate_top_y(index: int) -> float:
	return -(index + 1) * PLATE_HEIGHT


func _add_plate_visual(x: float, index: int, width: float, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.size = Vector2(width, PLATE_HEIGHT)
	rect.position = Vector2(x, _plate_top_y(index))
	plates_layer.add_child(rect)
	return rect


func _spawn_moving_plate() -> void:
	moving_width = current_max_width
	moving_color = pastel_palette[randi() % pastel_palette.size()]
	direction = 1 if (randi() % 2 == 0) else -1
	moving_x = play_left if direction == 1 else (play_right - moving_width)
	moving_local_y = _plate_top_y(stack_count) - SPAWN_GAP

	if moving_plate and is_instance_valid(moving_plate):
		moving_plate.queue_free()

	moving_plate = ColorRect.new()
	moving_plate.color = moving_color
	moving_plate.size = Vector2(moving_width, PLATE_HEIGHT)
	moving_plate.position = Vector2(moving_x, moving_local_y)
	world.add_child(moving_plate)

	state = State.MOVING


# ─── Per-frame update & input ─────────────────────────────────────────────────

func _process(delta: float) -> void:
	match state:
		State.MOVING:
			moving_x += direction * speed * delta
			if moving_x <= play_left:
				moving_x = play_left
				direction = 1
			elif moving_x + moving_width >= play_right:
				moving_x = play_right - moving_width
				direction = -1
			moving_plate.position.x = moving_x
		State.DROPPING:
			moving_local_y += DROP_SPEED * delta
			var landing_y := _plate_top_y(stack_count)
			if moving_local_y >= landing_y:
				moving_local_y = landing_y
				moving_plate.position.y = moving_local_y
				_resolve_landing()
			else:
				moving_plate.position.y = moving_local_y


func _unhandled_input(event: InputEvent) -> void:
	var triggered := false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		triggered = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		triggered = true

	if not triggered:
		return

	if state == State.START:
		start_panel.visible = false
		_start_game()
		get_viewport().set_input_as_handled()
		return

	if state == State.MOVING:
		state = State.DROPPING
		get_viewport().set_input_as_handled()


# ─── Landing resolution ───────────────────────────────────────────────────────

func _resolve_landing() -> void:
	var overlap_left: float = max(moving_x, current_top_x)
	var overlap_right: float = min(moving_x + moving_width, current_top_x + current_top_width)
	var overlap_width: float = overlap_right - overlap_left

	if overlap_width <= 0.0:
		_game_over()
		return

	var offset: float = moving_x - current_top_x
	var width_diff: float = abs(moving_width - current_top_width)
	var perfect: bool = (abs(offset) <= PERFECT_MARGIN) and (width_diff <= PERFECT_MARGIN)

	var placed_x: float
	var placed_width: float

	if perfect:
		placed_x = current_top_x
		placed_width = current_top_width
		_spawn_particles(placed_x + placed_width / 2.0, _plate_top_y(stack_count))
	else:
		placed_x = overlap_left
		placed_width = overlap_width

		if moving_x < overlap_left:
			_spawn_falling_piece(moving_x, overlap_left - moving_x, _plate_top_y(stack_count), moving_color)
		if moving_x + moving_width > overlap_right:
			_spawn_falling_piece(overlap_right, (moving_x + moving_width) - overlap_right, _plate_top_y(stack_count), moving_color)

	_add_plate_visual(placed_x, stack_count, placed_width, moving_color)
	current_top_x = placed_x
	current_top_width = placed_width
	current_max_width = placed_width

	moving_plate.queue_free()
	moving_plate = null

	stack_count += 1
	score += 1
	score_label.text = "Plates stacked: %d" % score
	speed += SPEED_INCREMENT

	_scroll_world()

	if score >= WIN_SCORE:
		_win_game()
	else:
		_spawn_moving_plate()


func _scroll_world() -> void:
	var tween := create_tween()
	tween.tween_property(world, "position:y", world.position.y + PLATE_HEIGHT, 0.22)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ─── Effects ──────────────────────────────────────────────────────────────────

func _spawn_particles(local_x: float, local_y: float) -> void:
	var particles := CPUParticles2D.new()
	particles.position = Vector2(local_x, local_y)
	particles.amount = 26
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 480)
	particles.initial_velocity_min = 90.0
	particles.initial_velocity_max = 230.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.5
	particles.color = Color(1.0, 0.96, 0.62)
	world.add_child(particles)
	particles.emitting = true
	get_tree().create_timer(particles.lifetime + 0.3).timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free()
	)


func _spawn_falling_piece(x: float, width: float, top_y: float, color: Color) -> void:
	if width <= 0.5:
		return
	var piece := ColorRect.new()
	piece.color = color
	piece.size = Vector2(width, PLATE_HEIGHT)
	piece.position = Vector2(x, top_y)
	piece.pivot_offset = piece.size / 2.0
	plates_layer.add_child(piece)

	var fall_distance: float = screen_size.y + abs(world.position.y) + 500.0
	var fall_time: float = sqrt(2.0 * fall_distance / FALL_GRAVITY)

	var tween := create_tween()
	tween.tween_property(piece, "position:y", top_y + fall_distance, fall_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(piece, "rotation_degrees", (randf() - 0.5) * 540.0, fall_time)
	tween.tween_callback(piece.queue_free)


# ─── End states ───────────────────────────────────────────────────────────────

func _game_over() -> void:
	state = State.GAME_OVER

	if moving_plate and is_instance_valid(moving_plate):
		_spawn_falling_piece(moving_x, moving_width, moving_local_y, moving_color)
		moving_plate.queue_free()
		moving_plate = null

	end_label.text = "Stack toppled!\n%d plates high." % score
	restart_button.visible = false
	secondary_button.visible = false
	end_panel.visible = true

	emit_signal("game_finished", false, score)
	await get_tree().create_timer(2.5).timeout
	queue_free()


func _win_game() -> void:
	state = State.WIN

	if moving_plate and is_instance_valid(moving_plate):
		moving_plate.queue_free()
		moving_plate = null

	end_label.text = "%d plates balanced without a wobble!" % score
	restart_button.visible = false
	secondary_button.visible = false
	end_panel.visible = true

	var parent := get_parent()
	if parent and ("passed" in parent):
		parent.passed = true

	emit_signal("game_finished", true, score)
	await get_tree().create_timer(2.5).timeout
	queue_free()


func _on_restart_pressed() -> void:
	_start_game()


func _on_secondary_pressed() -> void:
	if state != State.WIN:
		emit_signal("game_finished", false, score)
	queue_free()

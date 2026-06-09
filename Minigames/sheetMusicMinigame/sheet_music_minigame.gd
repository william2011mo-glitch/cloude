extends CanvasLayer

signal game_finished(won: bool, score: int)

const SEQUENCE: Array[String] = ["C", "E", "G", "B", "A", "G", "A", "C"]
const KEY_MAP: Dictionary = {
	KEY_A: "A",
	KEY_B: "B",
	KEY_C: "C",
	KEY_D: "D",
	KEY_E: "E",
	KEY_F: "F",
	KEY_G: "G",
}

@export var note_positions: Array[Vector2] = [
	Vector2(657, 355), Vector2(750, 355), Vector2(857, 355),
	Vector2(950, 355), Vector2(1087, 355), Vector2(1187, 355),
	Vector2(1280, 355), Vector2(1380, 355)
]

@export var cursor_bar_width: float = 14.0
@export var cursor_bar_height: float = 110.0

# Rhythm settings
@export var beat_interval: float = 1.0
@export var beat_tolerance: float = 0.35

var _current_index: int = 0
var _done: bool = false
var _started: bool = false
var _rhythm_started: bool = false
var _last_note_time: float = 0.0
var _x_labels: Array = []

@onready var _cursor: ColorRect = $Control/Cursor
@onready var _hint_label: Label = $Control/HintLabel
@onready var _overlay: Control = $Control

func _ready() -> void:
	_build_x_markers()
	_move_cursor_to(0)

	await _countdown()

	_started = true
	_update_hint()

func _countdown() -> void:
	for i in range(5, 0, -1):
		_hint_label.text = "Starting in " + str(i)
		await get_tree().create_timer(1.0).timeout

	_hint_label.text = "GO!"
	await get_tree().create_timer(0.5).timeout

func _build_x_markers() -> void:
	for pos in note_positions:
		var lbl := Label.new()
		lbl.text = "✗"
		lbl.add_theme_color_override("font_color", Color(0.692, 0.0, 0.024, 1.0))
		lbl.add_theme_font_size_override("font_size", 52)
		lbl.visible = false
		lbl.position = pos + Vector2(-16, -36)
		_overlay.add_child(lbl)
		_x_labels.append(lbl)

func _input(event: InputEvent) -> void:
	if _done or not _started:
		return

	if not (event is InputEventKey):
		return

	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_ESCAPE:
		emit_signal("game_finished", false, _current_index)
		queue_free()
		return

	var note: String = KEY_MAP.get(event.keycode, "")
	if note.is_empty():
		return

	_handle_note_input(note)

func _handle_note_input(note: String) -> void:
	# Wrong note immediately fails.
	if note != SEQUENCE[_current_index]:
		_x_labels[_current_index].visible = true
		_finish(false)
		return

	var now := Time.get_ticks_msec() / 1000.0

	# First note establishes the tempo.
	if not _rhythm_started:
		_rhythm_started = true
		_last_note_time = now
		_advance_note()
		return

	var delta := now - _last_note_time

	if abs(delta - beat_interval) > beat_tolerance:
		_x_labels[_current_index].visible = true
		_finish(false)
		return

	_last_note_time = now
	_advance_note()

func _advance_note() -> void:
	_current_index += 1

	if _current_index >= SEQUENCE.size():
		_finish(true)
		return

	_move_cursor_to(_current_index)
	_update_hint()

func _move_cursor_to(index: int) -> void:
	var pos := note_positions[index]
	_cursor.position = Vector2(
		pos.x - cursor_bar_width / 2.0,
		pos.y - cursor_bar_height / 2.0
	)

func _update_hint() -> void:
	_hint_label.text = (
		"Play: "
		+ SEQUENCE[_current_index]
		+ "  ("
		+ str(_current_index + 1)
		+ " / "
		+ str(SEQUENCE.size())
		+ ")"
	)

func _finish(won: bool) -> void:
	if _done:
		return

	_done = true

	if won:
		_hint_label.text = "Success!"
	else:
		_hint_label.text = "Wrong note or bad timing!"

	await get_tree().create_timer(1.0).timeout

	emit_signal("game_finished", won, _current_index)
	queue_free()

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

# Adjust these in the Inspector to line up with the note heads in the image.
# X = horizontal position of each note, Y = vertical center of the staff.
@export var note_positions: Array[Vector2] = [
	Vector2(657, 355), Vector2(750, 355), Vector2(857, 355),
	Vector2(950, 355), Vector2(1087, 355), Vector2(1187, 355),
	Vector2(1280, 355), Vector2(1380, 355)
]
@export var cursor_bar_width: float = 14.0
@export var cursor_bar_height: float = 110.0

var _current_index: int = 0
var _done: bool = false
var _x_labels: Array = []

@onready var _cursor: ColorRect = $Control/Cursor
@onready var _hint_label: Label = $Control/HintLabel
@onready var _overlay: Control = $Control

func _ready() -> void:
	_build_x_markers()
	_move_cursor_to(0)
	_update_hint()

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

func _unhandled_key_input(event: InputEvent) -> void:
	if _done or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		emit_signal("game_finished", false, _current_index)
		queue_free()
		return
	var note: String = KEY_MAP.get(event.keycode, "")
	if note.is_empty():
		return
	get_viewport().set_input_as_handled()
	_handle_note(note)

func _handle_note(note: String) -> void:
	if note == SEQUENCE[_current_index]:
		_current_index += 1
		if _current_index >= SEQUENCE.size():
			_finish(true)
		else:
			_move_cursor_to(_current_index)
			_update_hint()
	else:
		_x_labels[_current_index].visible = true
		_finish(false)

func _move_cursor_to(index: int) -> void:
	var pos := note_positions[index]
	_cursor.position = Vector2(pos.x - cursor_bar_width / 2.0, pos.y - cursor_bar_height / 2.0)

func _update_hint() -> void:
	_hint_label.text = "(HINT) Play: " + SEQUENCE[_current_index] + "   (" + str(_current_index + 1) + " / " + str(SEQUENCE.size()) + ")"

func _finish(won: bool) -> void:
	_done = true
	await get_tree().create_timer(1.0).timeout
	emit_signal("game_finished", won, _current_index)
	queue_free()

extends Control

@export var next_scene_path: String = "res://game.tscn"
@export var fade_duration: float = 1.5

@onready var instructions_text: RichTextLabel = $InstructionsText

var _can_continue := false
var _advancing := false

func _ready() -> void:
	instructions_text.modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	var tween := create_tween()
	tween.tween_property(instructions_text, "modulate:a", 1.0, fade_duration)
	tween.tween_callback(func(): _can_continue = true)

func _on_gui_input(event: InputEvent) -> void:
	if _can_continue and not _advancing:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_advance()

func _input(event: InputEvent) -> void:
	if _can_continue and not _advancing:
		if event is InputEventKey and event.pressed:
			_advance()

func _advance() -> void:
	_advancing = true
	var tween := create_tween()
	tween.tween_property(instructions_text, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(_go_to_next_scene)

func _go_to_next_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)

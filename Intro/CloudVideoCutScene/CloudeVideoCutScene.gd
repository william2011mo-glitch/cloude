extends Control

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var click_area: Control = $ClickArea

func _ready() -> void:
	click_area.gui_input.connect(_on_click_area_input)
	video_player.play()

func _on_click_area_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		video_player.paused = not video_player.paused

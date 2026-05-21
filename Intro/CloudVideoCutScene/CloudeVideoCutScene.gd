extends Control

@export var pause_times: Array[float] = []

@onready var video_player: VideoStreamPlayer = $VideoContainer/VideoStreamPlayer
@onready var click_zone: Control = $ClickZone

var _triggered: Array[bool] = []

func _ready() -> void:
	_triggered.resize(pause_times.size())
	_triggered.fill(false)
	click_zone.gui_input.connect(_on_click_zone_input)
	video_player.play()

func _process(_delta: float) -> void:
	if not video_player.is_playing() or video_player.paused:
		return
	for i in pause_times.size():
		if not _triggered[i] and video_player.stream_position >= pause_times[i]:
			video_player.paused = true
			_triggered[i] = true
			break

func _on_click_zone_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if video_player.paused:
			video_player.paused = false

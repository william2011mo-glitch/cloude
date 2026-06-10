extends CanvasLayer

signal gameFinished

@export var time_limit: float = 4.0
var timer: float

@onready var time_label: Label = $Control/Label

func _ready() -> void:
	timer = time_limit

func _process(delta: float) -> void:
	timer -= delta
	time_label.text = "Guard! Get out!\n%.1f" % max(timer, 0.0)
	if timer <= 0:
		emit_signal("gameFinished")

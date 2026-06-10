extends CanvasLayer
@onready var background : ColorRect = $Control/Background
@onready var time1 : ColorRect = $Control/Time1
@onready var time2 : ColorRect = $Control/Time2
@onready var player : ColorRect = $Control/Player

#1920 by 1080
#scaling problem again
func _ready() -> void:
	background.position = Vector2(300, 800);
	background.size = Vector2(1220, 200);
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

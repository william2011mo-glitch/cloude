extends ColorRect
var picCycle = [Color(), Color(1.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 1.0, 1.0), Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0)]
var hiddenColor = Color(0.307, 0.307, 0.307, 1.0)
@export var currentColorI = randi() % len(picCycle)
@export var time_until_hide = 1.5



func _ready() -> void:
	color = picCycle[currentColorI]
	await get_tree().create_timer(time_until_hide).timeout
	color = hiddenColor

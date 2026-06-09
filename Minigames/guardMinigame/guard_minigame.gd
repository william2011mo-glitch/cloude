extends Control
var timer = 2.0;
signal gameFinished

@onready var time: Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer-=delta;
	time.text = "%.2f" % timer;
	if(timer<0):
		emit_signal("gameFinished");

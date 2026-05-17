extends Control
signal minigame_finished
@onready var middle: TextureRect = $Middle
@onready var time_label: Label = $Time
var time = 3
var is_inside = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_minigame()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_label.text = str(time)
	changeTime()
	pass

func start_minigame():
	middle.mouse_entered.connect(inside)
	middle.mouse_exited.connect(outside)

func end_minigame():
	minigame_finished.emit()
	
func inside():
	is_inside = true
	
func outside():
	is_inside = false
	
func changeTime():
	#we can tweak the values
	if(is_inside):
		time+=0.01
	else:
		time-=0.01
	if(time>=3):
		time=2
	if(time<=0):
		print("time's up")
		get_tree().quit()

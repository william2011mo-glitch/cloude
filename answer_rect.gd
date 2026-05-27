extends ColorRect
var picCycle = [Color(), Color(1.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 1.0, 1.0), Color(0.0, 1.0, 0.0, 1.0), Color(1.0, 1.0, 1.0, 1.0)]
var currentColorI = randi() % len(picCycle)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = picCycle[currentColorI]





func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			currentColorI = (currentColorI+1) % len(picCycle)
			color = picCycle[currentColorI]
			

func _on_left_button_pressed():
	get_tree().change_scene_to_file("res://RoomScenes/Down_stairs_second_from_top.tscn")

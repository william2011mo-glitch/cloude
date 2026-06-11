extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var visibleArrows = $RoomManager.fetch_possible_directions()
	
	if visibleArrows.has('left'):
		$LeftArrow.visible = true
	else: $LeftArrow.visible = false
	if visibleArrows.has('forward'):
		$ForwardArrow.visible = true
	else: $ForwardArrow.visible = false
	if visibleArrows.has('back'):
		$BackArrow.visible = true
	else: $BackArrow.visible = false
	if visibleArrows.has('right'):
		$RightArrow.visible = true
	else: $RightArrow.visible = false

func _on_left_arrow_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$RoomManager.move("left")


func _on_right_arrow_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$RoomManager.move("right")


func _on_back_arrow_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$RoomManager.move("back")


func _on_forward_arrow_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$RoomManager.move("forward")

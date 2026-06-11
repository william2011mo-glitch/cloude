extends Node2D

var minigame_open = false

func _on_boy_thing_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("two_boys"):
<<<<<<< HEAD
			return
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("two_boys_painting"):
=======
>>>>>>> parent of 1ed05df (sa)
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/colorMinigame/colorMinigame.tscn").instantiate()
		add_child(mg)
		mg.game_finished.connect(_on_color_finished)


func _on_color_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("the Duo")
		HeistHUD.mark_attempted("two_boys")

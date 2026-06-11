extends Node2D

var minigame_open := false


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open: return
		if HeistHUD.has_attempted("jewel_box"):
			HeistHUD.show_already_tried_popup(); return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/traversalMinigame/traversalMinigame.tscn").instantiate()
		mg.game_finished.connect(_on_traversal_finished)
		# Add to HeistHUD so the Control renders on top of the room
		HeistHUD.add_child(mg)


func _on_traversal_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	HeistHUD.mark_attempted("jewel_box")
	if won:
		HeistHUD.steal_item("The Diamond Necklace", 3)

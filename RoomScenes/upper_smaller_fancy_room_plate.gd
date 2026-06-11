extends Node2D

var minigame_open := false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("porcelain_plate"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/platformMinigame/platformMinigame.tscn").instantiate()
		mg.game_finished.connect(_on_platform_finished)
		add_child(mg)

func _on_platform_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.mark_attempted("porcelain_plate")
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("The Porcelain Plate", 1)

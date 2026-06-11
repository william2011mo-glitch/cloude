extends Node2D

var minigame_open = false

func _on_piano_close_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("blue_vase"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/glassMinigame/glass_cutting_minigame.tscn").instantiate()
		add_child(mg)
		mg.game_finished.connect(_on_glass_finished)


func _on_glass_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	HeistHUD.mark_attempted("blue_vase")
	if won:
		HeistHUD.steal_item("the Blue Vase")

func _on_hateful_door_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_parent().move("hateful_door")

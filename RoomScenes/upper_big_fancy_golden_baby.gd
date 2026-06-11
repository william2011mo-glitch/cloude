extends Node2D

var minigame_open = false

func _on_gold_gold_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("golden_baby"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/traversalMinigame/traversalMinigame.tscn").instantiate()
		add_child(mg)
		mg.game_finished.connect(_on_traversal_finished)


func _on_traversal_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("the Cherub")
		HeistHUD.mark_attempted("golden_baby")

extends Node2D

var minigame_open = false

func _on_lady_is_painting_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("lady_painting"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/timedMinigame/timedMinigame.tscn").instantiate()
		add_child(mg)
		mg.game_finished.connect(_on_timed_finished)

func _on_timed_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("the Opera Singer")
		HeistHUD.mark_attempted("lady_painting")

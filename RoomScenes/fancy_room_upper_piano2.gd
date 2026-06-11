extends Node2D

var minigame_open = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if minigame_open:
				return
			if HeistHUD.has_attempted("midnight_sonata"):
				HeistHUD.show_already_tried_popup()
				return
			minigame_open = true
			HeistHUD.minigame_active = true
			var minigame = load("res://Minigames/sheetMusicMinigame/sheetMusicMinigame.tscn")
			var instance = minigame.instantiate()
			instance.game_finished.connect(_on_sheet_music_finished)
			add_child(instance)

func _on_sheet_music_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.mark_attempted("midnight_sonata")
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("The Midnight Sonata Score")
		get_parent().move("forward")

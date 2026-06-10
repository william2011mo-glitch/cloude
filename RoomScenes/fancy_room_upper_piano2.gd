extends Node2D

var minigame_open = false
var attempted = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if minigame_open or attempted:
				return
			minigame_open = true
			HeistHUD.minigame_active = true
			var minigame = load("res://Minigames/sheetMusicMinigame/sheetMusicMinigame.tscn")
			var instance = minigame.instantiate()
			instance.game_finished.connect(_on_sheet_music_finished)
			add_child(instance)

func _on_sheet_music_finished(won: bool, _score: int) -> void:
	minigame_open = false
	attempted = true
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("The Midnight Sonata Score")
		get_parent().move("forward")

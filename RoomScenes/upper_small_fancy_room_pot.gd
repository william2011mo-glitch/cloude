extends Node2D

var minigame_open := false

func _ready() -> void:
	$TextureRect.visible = true
	$revealed.visible    = false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("diamond"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/timedMinigame/timedMinigame.tscn").instantiate()
		mg.game_finished.connect(_on_timed_finished)
		add_child(mg)

func _on_timed_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	HeistHUD.mark_attempted("diamond")
	if won:
		$TextureRect.visible = false
		$revealed.visible    = true
		HeistHUD.steal_item("The Diamond", 3)

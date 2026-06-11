extends Node2D

func _ready() -> void:
	$TextureRect.visible = true
	$revealed.visible    = false

var minigame_open = false

func _on_pot_pot_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_open:
			return
		if HeistHUD.has_attempted("pot"):
			HeistHUD.show_already_tried_popup()
			return
		minigame_open = true
		HeistHUD.minigame_active = true
		var mg = load("res://Minigames/platformMinigame/platformMinigame.tscn").instantiate()
		add_child(mg)
		mg.game_finished.connect(_on_platform_finished)

func _on_platform_finished(won: bool, _score: int) -> void:
	minigame_open = false
	HeistHUD.minigame_active = false
	if won:
		HeistHUD.steal_item("the Jewel")
		HeistHUD.mark_attempted("pot")
		$TextureRect.visible = false
		$revealed.visible    = true

extends Node2D

var passed = false
var attempted = false
var minigame_open = false

func _ready() -> void:
	$TextureRect.visible = !passed
	$opened.visible = passed

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if passed or attempted or minigame_open:
				return
			minigame_open = true
			HeistHUD.minigame_active = true
			var minigame = load("res://Minigames/stackerMinigame/stackerMinigame.tscn")
			var instance = minigame.instantiate()
			instance.game_finished.connect(_on_stacker_finished)
			add_child(instance)

func _on_stacker_finished(won: bool, _score: int) -> void:
	minigame_open = false
	attempted = true
	HeistHUD.minigame_active = false
	if won:
		passed = true
		$TextureRect.visible = false
		$opened.visible = true
		HeistHUD.steal_item("The Porcelain Collection", 2)

extends Node2D

var passed = false
var attempted = false
var minigame_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.visible = !passed
	$revealed.visible = passed


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if passed or attempted or minigame_open:
				return

			minigame_open = true
			HeistHUD.minigame_active = true
			var minigame = load("res://Minigames/stackerMinigame/stackerMinigame.tscn")
			var init = minigame.instantiate()
			init.game_finished.connect(_on_stacker_finished)
			self.add_child(init)


func _on_stacker_finished(won: bool, _score: int) -> void:
	minigame_open = false
	attempted = true
	HeistHUD.minigame_active = false
	if won:
		passed = true
		$TextureRect.visible = false
		$revealed.visible = true
		HeistHUD.steal_item("The Diamond Pot")

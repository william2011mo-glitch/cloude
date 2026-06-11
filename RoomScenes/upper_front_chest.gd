extends Node2D
var minigame_should_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.visible = true
	$Reveal.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			if minigame_should_open:
				return
			if HeistHUD.has_attempted("open_chest"):
				HeistHUD.show_already_tried_popup()
				return
			minigame_should_open = true
			HeistHUD.minigame_active = true
			var minigame_wires = load("res://Minigames/wiresMinigame/wiresMinigame.tscn")
			var new = minigame_wires.instantiate()
			add_child(new)
			await get_tree().tree_changed
			await get_tree().tree_changed
			$TextureRect.visible = !$TextureRect.visible
			$Reveal.visible = !$Reveal.visible
			HeistHUD.mark_attempted("open_chest")
			HeistHUD.steal_item("Golden Coins")

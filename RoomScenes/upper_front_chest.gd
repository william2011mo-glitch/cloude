extends Node2D

var minigame = load("res://Minigames/wiresMinigame/wiresMinigame.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.visible = false
	$Reveal.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			var new = minigame.instantiate()
			add_child(new)
			await get_tree().tree_changed
			$TextureRect.visible = !$TextureRect.visible
			$Reveal.visible = !$Reveal.visible

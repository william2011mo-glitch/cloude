extends Control
@onready var traversal: Button = $Traversal
@onready var mouse: Button = $Mouse
@onready var wires: Button = $Wires

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	traversal.pressed.connect(toTraversal);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func toTraversal():
	get_tree().change_scene_to_file("res://Minigames/traversalMinigame/traversalMinigame.tscn")

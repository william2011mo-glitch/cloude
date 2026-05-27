extends Control
@onready var traversal: Button = $Traversal
@onready var mouse: Button = $Mouse
@onready var wires: Button = $Wires
@onready var cloude: Button = $Cloude

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	traversal.pressed.connect(toTraversal);
	wires.pressed.connect(toWires);
	mouse.pressed.connect(toMouse);
	cloude.pressed.connect(toCloude);


func toTraversal():
	get_tree().change_scene_to_file("res://Minigames/traversalMinigame/traversalMinigame.tscn")
func toWires():
	get_tree().change_scene_to_file("res://Minigames/wiresMinigame/wiresMinigame.tscn")
func toMouse():
	get_tree().change_scene_to_file("res://Minigames/mouseMinigame/canvas_layer.tscn")
func toCloude():
	get_tree().change_scene_to_file("res://Intro/CloudVideoCutScene/CloudeVideoCutScene.tscn")

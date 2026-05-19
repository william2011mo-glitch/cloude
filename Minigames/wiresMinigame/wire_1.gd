extends Node2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var hitbox: Area2D = $Area2D
var isDragging = false;
var freeEnd = Vector2(0, 0);
var anchor = Vector2(0, 0);

func _ready() -> void:
	updateWire();


func _process(delta: float) -> void:
	hitbox.input_event.connect(clicked);
	
	
func clicked(event: InputEvent):
	if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		if(event.pressed):
			isDragging = true;
		else:
			isDragging = false;

#.normalized sets the magnitude of the vector to 1
func updateWire():
	
	pass

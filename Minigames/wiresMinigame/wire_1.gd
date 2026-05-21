extends Node2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var hitbox: Area2D = $Area2D
var isDragging = false;
var freeEnd = Vector2(500, 600);
var anchor = Vector2(100, 600);

func _ready() -> void:
	polygon.color = Color.RED
	hitbox.input_event.connect(_on_area_2d_input_event);
	#.position is it relative to the parent node hence the -global_position
	hitbox.position = to_local(freeEnd) - Vector2(300, 0);
	updateWire();

func _process(_delta: float) -> void:
	if(isDragging):
		freeEnd = get_global_mouse_position();
		updateWire();
		hitbox.position = to_local(freeEnd) - Vector2(300, 0);
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			isDragging = false
	

#.normalized sets the magnitude of the vector to 1
func updateWire():
	var direction = Vector2(freeEnd-anchor).normalized();
	var perp = Vector2(-direction.y, direction.x)*100;
		
	polygon.polygon = [
		to_local(anchor + perp),
		to_local(anchor - perp),
		to_local(freeEnd - perp),
		to_local(freeEnd + perp)
		];
	hitbox.position = to_local(freeEnd) - Vector2(150, 0);


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		if(event.pressed):
			isDragging = true;

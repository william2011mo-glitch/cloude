extends Node2D

signal wireConnected

@onready var polygon: Polygon2D = $Polygon2D
@onready var hitbox: Area2D = $Area2D

var color = Color.RED
var isDragging = false;
var freeEnd = Vector2(500, 400);
var anchor = Vector2(100, 400);
var startPos = Vector2(500, 400);
var target = Vector2(1700, 430);
var tol = 100;
var connected = false;

func _ready() -> void:	
	polygon.color = color
	hitbox.input_event.connect(_on_area_2d_input_event);
	updateWire();
	
	var targetDisplay = ColorRect.new() #this is actually pretty useful.
	targetDisplay.color = color
	targetDisplay.size = Vector2(200, 200);
	targetDisplay.position = target-Vector2(100, 100);
	add_child(targetDisplay)

func _process(_delta: float) -> void:
	if(isDragging):
		freeEnd = getMousePos()
		updateWire();
		hitbox.position = freeEnd;
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			isDragging = false
			snap();
	

func updateWire():
	#.normalized sets the magnitude of the vector to 1
	var direction = Vector2(freeEnd-anchor).normalized();
	var perp = Vector2(-direction.y, direction.x)*75;
		
	polygon.polygon = [anchor + perp, anchor - perp, freeEnd - perp, freeEnd + perp];
	hitbox.position = freeEnd-Vector2(150, 0);

func snap():
	if(get_local_mouse_position().distance_to(target)<=tol):
		#tries to snap to target location
		freeEnd = getScaledPos(target);
		connected = true;
		hitbox.position = freeEnd
		updateWire()
		emit_signal("wireConnected")
	else:
		#if not just go back
		reset();

func reset():
	freeEnd = startPos;
	updateWire();

#TLDR scaling is terrible in godot so you have to use this rounabout way to do it.
func getMousePos() -> Vector2:
	var scale_x = polygon.global_transform.x.x
	var scale_y = polygon.global_transform.y.y
	var mouse = get_viewport().get_mouse_position()
	return Vector2(mouse.x / scale_x, mouse.y / scale_y)
#correct implementation

func getScaledPos(pos: Vector2) -> Vector2:
	var scale_x = polygon.global_transform.x.x
	var scale_y = polygon.global_transform.y.y
	return Vector2(pos.x / scale_x, pos.y / scale_y)


#if you click on the wire's hitbox
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if(connected):
		return
	if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		if(event.pressed):
			isDragging = true;

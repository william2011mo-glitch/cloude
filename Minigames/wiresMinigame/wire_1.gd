extends Node2D

@onready var polygon: Polygon2D = $Polygon2D
@onready var hitbox: Area2D = $Area2D
var isDragging = false;
var freeEnd = Vector2(500, 600);
var anchor = Vector2(100, 600);
var startPos = Vector2(500, 600);
var target = Vector2(1600, 300);
var tol = 150;
var connected = false;

func _ready() -> void:	
	polygon.color = Color.RED
	hitbox.input_event.connect(_on_area_2d_input_event);
	updateWire();
	
	var targetDisplay = ColorRect.new() #this is actually pretty useful.
	targetDisplay.color = Color.RED
	targetDisplay.size = Vector2(300, 300);
	targetDisplay.position = target-Vector2(150, 150);
	add_child(targetDisplay)

func _process(_delta: float) -> void:
	if(isDragging):
		freeEnd = get_local_mouse_position();
		var localMouse = get_local_mouse_position()
		var viewportMouse = get_viewport().get_mouse_position()
		print("local mouse: ", localMouse, " viewport mouse: ", viewportMouse, " freeEnd: ", freeEnd)
		updateWire();
		hitbox.position = freeEnd;
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			isDragging = false
			snap();
	

func updateWire():
	#.normalized sets the magnitude of the vector to 1
	var direction = Vector2(freeEnd-anchor).normalized();
	var perp = Vector2(-direction.y, direction.x)*100;
		
	polygon.polygon = [anchor + perp, anchor - perp, freeEnd - perp, freeEnd + perp];
	print("freeEnd: ", freeEnd, " polygon freeEnd corner: ", freeEnd - perp)
	hitbox.position = freeEnd;

func snap():
	if(freeEnd.distance_to(target)<=tol):
		#tries to snap to target location
		freeEnd = target;
		connected = true;
		hitbox.position = freeEnd
		updateWire()
	else:
		#if not just go back
		reset();

func reset():
	freeEnd = startPos;
	updateWire();

#if you click on the wire's hitbox
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if(connected):
		return
	if(event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT):
		if(event.pressed):
			isDragging = true;

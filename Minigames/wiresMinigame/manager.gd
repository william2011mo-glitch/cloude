extends Node2D

const Wire = preload("res://Minigames/wiresMinigame/wire_1.tscn")
var wires = []

func _ready() -> void:
	spawnWire(Vector2(100, 150), Vector2(500, 150), Vector2(1600, 150), Color.YELLOW)
	spawnWire(Vector2(100, 650), Vector2(500, 650), Vector2(1600, 650), Color.BLUE)
	spawnWire(Vector2(100, 900), Vector2(500, 900), Vector2(1600, 900), Color.GREEN)

#just makes a bunch of other wires
func spawnWire(anchorPos: Vector2, startPosition: Vector2, targetPos: Vector2, wColor: Color):
	var wire = Wire.instantiate()
	wire.anchor = anchorPos;
	wire.freeEnd = startPosition;
	wire.startPos = startPosition;
	wire.target = targetPos;
	wire.color = wColor;
	add_child(wire);
	wire.wireConnected.connect(end)
	wires.append(wire)

func end():
	if(wires.all(func(w): return w.connected)):
		print("done")

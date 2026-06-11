extends Node2D
signal game_finished(won:bool, score:int)

const Wire = preload("res://Minigames/wiresMinigame/wire_1.tscn")
var wires = []
var startPos = [150, 400, 650, 900];
var endPos = [160, 430, 700, 950];
func _ready() -> void:
	startPos.shuffle(); 
	endPos.shuffle();
	#for some reason the targetPos is a bit off so I'm adjusting it a little
	spawnWire(Vector2(100, startPos[0]), Vector2(500, startPos[0]), Vector2(1700, endPos[0]), Color.YELLOW)
	spawnWire(Vector2(100, startPos[1]), Vector2(500, startPos[1]), Vector2(1700, endPos[1]), Color.RED)
	spawnWire(Vector2(100, startPos[2]), Vector2(500, startPos[2]), Vector2(1700, endPos[2]), Color.BLUE)
	spawnWire(Vector2(100, startPos[3]), Vector2(500, startPos[3]), Vector2(1700, endPos[3]), Color.GREEN)

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
		emit_signal("game_finished", true, 0)
		queue_free()

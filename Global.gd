extends Node
#RUN EVERYTHING GLOBAL HERE
var paintings = [];
var money = 0;
@onready var guardTime: Timer = $guardTimer
@onready var gameTime: Timer = $gameTimer

var guardRoom = "GrandDrawingRoom";
var GrandDrawingRoom = [];
var SmallDrawingRoom = [];
var MorningRoom = [];
var PorcelainRoom = [];
var UpperVestibule = [];
var LowerVestibule = [];



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#guardTime.timeout.connect(guardMove());
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func guardMove():
	if(guardRoom=="GrandDrawingRoom"):
		var rand = randi_range(1, 2);
		if(rand==1):
			guardRoom = "MorningRoom";
		else:
			guardRoom = "SmallDrawingRoom";
	elif(guardRoom=="SmallDrawingRoom"):
		var rand = randi_range(1, 2);
		if(rand==1):
			guardRoom = "GrandDrawingRoom";
		else:
			guardRoom = "MorningRoom";
	elif(guardRoom=="MorningRoom"):
		var rand = randi_range(1, 3);
		if(rand==1):
			guardRoom = "GrandDrawingRoom";
		elif(rand==2):
			guardRoom = "SmallDrawingRoom";
		else:
			guardRoom = "UpperVestibule";
	elif(guardRoom=="UpperVestibule"):
		var rand = randi_range(1, 3);
		if(rand==1):
			guardRoom = "MorningRoom";
		elif(rand==2):
			guardRoom = "PorcelainRoom";
		else:
			guardRoom = "LowerVestibule"
	else:
		guardRoom = "UpperVestibule"


func guardCheck():
	pass

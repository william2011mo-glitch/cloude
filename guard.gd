extends Node

var paintings = [];
var paintingsFailed = [];

var money = 0;
var guardTime = 0.0;

var guardRoom = "LowerVestibule";
var GrandDrawingRoom = ["Big_DR_enter", "Big_DR_leaving"];
var SmallDrawingRoom = ["Small_pot_room", "Small_pot_room_right", "Smaller_room_to_small_room", "Small_pot_right_2",
 "Small_pot_right_2", "pot"];
var MorningRoom = ["Upper_middle_forward_final", "Upper_middle_right_leaving", "Upper_middle_back_1",
 "Upper_middle_forward_1", "Upper_middle_forward_2",
 "Upper_middle_room_opposite", "Upper_middle_right", "Upper_middle_room_turned"];
var PorcelainRoom = ["case", "Smaller_room"];
var UpperVestibule = ["Down_stairs_2", "Upper_main", "Upper_door_closer", "chest",
 "Upper_main_left_turn", "Leaving_upper_middle", "Up_stairs_2"];
var LowerVestibule = ["Down_stairs_1", "Opening_first", "Opening_right", "Up_stairs_1", "Down_stairs_to_opening"];



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	guardTime+=delta;
	if(guardTime-20>0):
		guardTime-=20;
		guardMove();
		print(guardRoom)
	
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

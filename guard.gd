extends Node

var paintings = [];
var paintingsFailed = [];

var on = true;
var money = 0;
var guardTime = 0.0;

var guardRoom = "GrandDrawingRoom";
var GrandDrawingRoom = ["Big_DR_enter", "Big_DR_leaving", "Big_DR_Left_Piano", "Big_Piano_Close", "Big_Piano_Closer", 
"Big_Piano_From_Opposite", "Big_DR_golden_baby", "Big_DR_vase", "Big_DR_right"]

var SmallDrawingRoom = ["Small_pot_room", "Small_pot_room_right", "Smaller_room_to_small_room", "Smaller_room_to_small_room_step", 
"Small_pot_right_2", "Small_pot_right_2", "pot", "Smaller_vase", "Small_room_turned_around", ]

var MorningRoom = ["Upper_middle_room_enter", "Two_boys", "Upper_middle_room_turned",
	"Leaving_upper_middle", "Upper_middle_forward_1", "Upper_middle_back_1",
	"Upper_middle_forward_2", "Upper_middle_room_opposite", "Upper_middle_lady",
	"Upper_middle_right", "Upper_middle_right_leaving", "Upper_middle_right_back",
	"Upper_middle_jewels", "Upper_middle_forward_final"]
	
var PorcelainRoom = ["Smaller_room", "Smaller_room_left", "Smaller_room_left_turned",
	"case", "Smaller_room_plate", "Smaller_room_plate_turn_around", "Smaller_room_door_leave"]
	
var UpperVestibule = ["Upper_main", "chest", "Upper_door_closer", "Upper_main_left_turn",
	"Upper_main_left_turn_then_around", "Up_stairs_2", "Down_stairs_2"]
	
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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_P and event.pressed and not event.echo:
			on = !on
			print(on);
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

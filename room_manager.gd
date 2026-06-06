extends Node

var rooms = {
	"Opening_first": {
		"scene": "res://RoomScenes/Opening.tscn",
		"exits": {
			"right": "Opening_right",
			"forward": "Up_stairs_1"
		}
	},

	"Opening_right": {
		"scene": "res://RoomScenes/Opening_right.tscn",
		"exits": {
			"left": "Opening_first"
		}
	},

	"Up_stairs_1": {
		"scene": "res://RoomScenes/opening_to_stairs.tscn",
		"exits": {
			"forward": "Up_stairs_2",
			"back": "Down_stairs_to_opening"
		}
	},

	"Up_stairs_2": {
		"scene": "res://RoomScenes/up_stairs.tscn",
		"exits": {
			"forward": "Upper_main",
			"back": "Down_stairs_2"
		}
	},
	
	"Upper_main": {
		"scene": "res://RoomScenes/stairs_to_front_upper_entrance.tscn",
		"exits": {
			"left": "Upper_main_left_turn",
			"back": "Down_stairs_2",
			"chest": "chest",
			"middle_door": "Upper_door_closer"
		},
	},
	
	"chest": {
		"scene": "res://RoomScenes/upper_front_chest.tscn",
		"exits": {
			"back": "Upper_main"
		}
	},
	
	"Upper_door_closer": {
		"scene": "res://RoomScenes/upper_floor_middle_door.tscn",
		"exits": {
			"back": "Upper_main",
			"actual_door": "Upper_middle_room_enter"
		}
	},
	
	"Upper_main_left_turn": {
		"scene": "res://RoomScenes/Upper_front_left_turn.tscn",
		"exits": {
			"back": "Upper_main_left_turn_then_around",
			"door_thing": "Smaller_room"
		}
	},
	
	"Upper_main_left_turn_then_around": {
		"scene": "res://RoomScenes/Upper_front_left_turned_around.tscn",
		"exits": {
			"back": "Upper_main_left_turn",
			"forward": "Upper_main",
			"chest": "chest"
		}
	},
	
	"Upper_middle_room_enter": {
		"scene": "res://RoomScenes/upper_middle_entered_first.tscn",
		"exits": {
			"back": "Upper_middle_room_turned",
			"left": "Upper_middle_forward_1",
			"right": "Upper_middle_forward_2"
		}
	},
	"Two_boys": {
		"scene": "res://RoomScenes/upper_middle_two_boys.tscn",
		"exits": {
			"back": "Upper_middle_room_opposite",
			"right": "Upper_middle_forward_final"
		}
	},
	"Upper_middle_room_turned": {
		"scene": "res://RoomScenes/upper_middle_room_turned_around.tscn",
		"exits": {
			"back": "Upper_middle_room_enter",
			"door_going": "Leaving_upper_middle"
		}
	},
	"Leaving_upper_middle": {
		"scene": "res://RoomScenes/upper_leaving_middle.tscn",
		"exits": {
			"forward": "Down_stairs_2",
			"back": "Upper_door_closer",
			"right": "Upper_main_left_turn"
		}
	},
	"Upper_middle_forward_1": {
		"scene": "res://RoomScenes/upper_middle_room_forward_one.tscn",
		"exits": {
			"forward": "Upper_middle_forward_final",
			"back": "Upper_middle_back_1"
		}
	},
	"Upper_middle_back_1": {
		"scene": "res://RoomScenes/upper_middle_room_backward_one.tscn",
		"exits": {
			"forward": "Upper_middle_room_turned",
			"back": "Upper_middle_forward_1"
		}
	},
	"Upper_middle_forward_2": {
		"scene": "res://RoomScenes/upper_middle_room_forward_two.tscn",
		"exits": {
			"forward": "Upper_middle_forward_final",
			"left": "Upper_middle_right_leaving",
			"right": "Upper_middle_right",
			"back": "Upper_middle_room_enter"
		}
	},
	"Upper_middle_room_opposite": {
		"scene": "res://RoomScenes/upper_middle_room_from_opposite.tscn",
		"exits": {
			"right": "Upper_middle_back_1",
			"back": "Upper_middle_forward_final"
		}
	},
	"Upper_middle_right": {
		"scene": "res://RoomScenes/upper_middle_room_right_turn.tscn",
		"exits": {
			"door_im_done_with_naming": "Smaller_room_to_small_room",
			"left": "Upper_middle_forward_2",
			"back": "Upper_middle_right_leaving"
		}
	},
	"Upper_middle_right_leaving": {
		"scene": "res://RoomScenes/upper_middle_right_turn_leaving.tscn",
		"exits": {
			"right": "Upper_middle_forward_2",
			"back": "Upper_middle_right"
		}
	},
	"Upper_middle_forward_final": {
		"scene": "res://RoomScenes/Upper_middle_forward_final.tscn",
		"exits": {
			"door_yes": "Big_DR_enter",
			"back": "Upper_middle_room_opposite",
			"boy_painting": "Two_boys"
		}
	},
	
	"Big_DR_enter": {
		"scene": "res://RoomScenes/fancy_room_upper_first.tscn",
		"exits": {
			"back": "Upper_middle_forward_final",
			#"forward": "Golden_Baby",
			"right": "Big_DR_right"
		}
	},
	"Big_DR_right": {
		"scene": "res://RoomScenes/fancy_room_upper_right.tscn",
		"exits": {
			"back": "Big_DR_leaving",
			"door_this_one": "Small_pot_room",
		}
	},
	"Big_DR_leaving": {
		"scene": "res://RoomScenes/fancy_upper_right_leaving.tscn",
		"exits": {
			"back": "Big_DR_right",
			"left": "Big_DR_enter",
		}
	},
	"Small_pot_room": {
		"scene": "res://RoomScenes/upper_right_small_fancy_room.tscn",
		"exits": {
			"right": "Small_pot_room_right",
			"pot_from_far": "pot",
			"back": "Small_room_turned_around"
		}
	},
	"pot": {
		"scene": "res://RoomScenes/upper_small_fancy_room_pot.tscn",
		"exits": {
			"back": "Small_pot_room",
		}
	},
	"Small_pot_room_right": {
		"scene": "res://RoomScenes/upper_right_small_fancy_room_right.tscn",
		"exits": {
			"right": "Small_pot_right_2",
			"back": "Leaving_morning_room_right_2"
		}
	},
	"Small_pot_right_2": {
		"scene": "res://RoomScenes/upper_small_fancy_room_2right.tscn",
		"exits": {
			"door_um": "Upper_middle_right_leaving",
			"back": "Smaller_room_to_small_room"
		}
	},
	"Smaller_room_to_small_room": {
		"scene": "res://RoomScenes/upper_small_fancy_room_leaving_to_small_room_1.tscn",
		"exits": {
			"forward": "Smaller_room_to_small_room_step",
			"back": "Small_pot_right_2"
		}
	},
	"Smaller_room_to_small_room_step": {
		"scene": "res://RoomScenes/upper_small_leaving_to_small_2.tscn",
		"exits": {
			"left": "Small_room_turned_around",
			"right": "Small_pot_room",
			"back": "Small_pot_room_right"
		}
	},
	"Small_room_turned_around": {
		"scene": "res://RoomScenes/upper_small_turned_around.tscn",
		"exits": {
			"door_idk": "Big_DR_leaving",
			"back": "Small_pot_room"
		}
	},
	"Smaller_room": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_first.tscn",
		"exits": {
			"back": "the turn back that shira took a picture of",
			"left": "Smaller_room_left"
		}
	},
	"Smaller_room_left": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_left.tscn",
		"exits": {
			"back": "Smaller_room_left_turned",
			"forward": "case"
		}
	},
	"Smaller_room_left_turned": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_case_turned.tscn",
		"exits": {
			"back": "case"
		}
	},
	"case": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_case.tscn",
		"exits": {
			"back": "Smaller_room_left_turned"
		}
	},
	
	"Down_stairs_2": {
		"scene": "res://RoomScenes/Down_stairs_first_from_top.tscn",
		"exits": {
			"forward": "Down_stairs_1",
			"back": "Up_stairs_2"
		}
	},
	"Down_stairs_1": {
		"scene": "res://RoomScenes/Down_stairs_second_from_top.tscn",
		"exits": {
			"forward": "Down_stairs_to_opening",
			"back": "Up_stairs_2"
		}
	},
	"Down_stairs_to_opening": {
		"scene": "res://RoomScenes/stairs_to_opening.tscn",
		"exits": {
			"forward": "Opening_first",
			"back": "Up_stairs_1"
		}
	},
}

var current_room = "Opening_first"

func _ready() -> void:
	load_room()

var is_changing_room = false

func move(direction):
	if is_changing_room:
		return
		
	is_changing_room = true
	var exits = rooms[current_room]["exits"]
	
	if exits.has(direction):
		current_room = exits[direction]
		print("new room:", current_room)
		load_room()
	else:
		print("No room in that direction")
		
	await get_tree().process_frame
	is_changing_room = false

func load_room():
	var scene_path = rooms[current_room]["scene"]
	
	for c in self.get_children():
		c.queue_free()
	var currnode = load(scene_path)
	var z = currnode.instantiate()
	self.add_child(z)
func fetch_possible_directions():
	return rooms[current_room]["exits"]

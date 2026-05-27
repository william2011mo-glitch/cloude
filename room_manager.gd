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
			"right": "Up_stairs_2",
			"forward": "Up_stairs_2",
			"back": "Opening_first"
		}
	},

	"Up_stairs_2": {
		"scene": "res://RoomScenes/up_stairs.tscn",
		"exits": {
			"forward": "Upper_main",
			"back": "Up_stairs_1"
		}
	},
	
	"Upper_main": {
		"scene": "res://RoomScenes/stairs_to_front_upper_entrance.tscn",
		"exits": {
			"forward": "Upper_middle_room_enter",
			"left": "Upper_main_left_turn",
			"right": "Upper_main_right_turn",
			"back": "down_stairs_2",
			"chest": "chest"
		}
	},
	
	"chest": {
		"scene": "res://RoomScenes/upper_front_chest.tscn",
		"exits": {
			"back": "Upper_main"
		}
	},
	
	"Upper_main_left_turn": {
		"scene": "res://RoomScenes/Upper_front_left_turn.tscn",
		"exits": {
			"back": "Upper_main"
		}
	},
	
	"Upper_main_right_turn": {
		"scene": "res://RoomScenes/Upper_front_right_turn.tscn",
		"exits": {
			"back": "Upper_main"
		}
	},
	"Upper_middle_room_enter": {
		"scene": "res://RoomScenes/upper_middle_entered_first.tscn",
		"exits": {
			"back": "leaving_upper_middle",
			"forward": "Upper_middle_forward_2",
			"right": "Upper_middle_right"
		}
	},
	"leaving_upper_middle": {
		"scene": "res://RoomScenes/upper_leaving_middle.tscn",
		"exits": {
			"forward": "down_stairs_2"
		}
	},
	"Upper_middle_forward_2": {
		"scene": "res://RoomScenes/upper_middle_room_forward_one.tscn",
		"exits": {
			"forward": "Upper_middle_forward_final",
			"right": "Upper_middle_right",
			"back": "Upper_middle_room_enter"
		}
	},
	"Upper_middle_right": {
		"scene": "res://RoomScenes/upper_middle_room_right_turn.tscn",
		"exits": {
			"left": "Upper_middle_forward_2",
			"back": "Upper_middle_room_enter"
		}
	},
	"Upper_middle_forward_final": {
		"scene": "res://RoomScenes/Upper_middle_forward_final.tscn",
		"exits": {
			"forward": "Morning_room_enter",
			"back": "Upper_middle_forward_2"
		}
	},
	
	"Morning_room_enter": {
		"scene": "res://RoomScenes/fancy_room_upper_first.tscn",
		"exits": {
			"back": "Upper_middle_forward_final",
			#"forward": "Golden_Baby",
			"right": "Morning_room_right"
		}
	},
	"Morning_room_right": {
		"scene": "res://RoomScenes/fancy_room_upper_right.tscn",
		"exits": {
			"back": "Morning_room_enter",
			"forward": "Small_pot_room",
		}
	},
	"Small_pot_room": {
		"scene": "res://RoomScenes/upper_right_small_fancy_room.tscn",
		"exits": {
			"right": "Small_pot_room_right",
			"forward": "pot",
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
			"forward": "Smaller_room",
			"back": "Leaving_morning_room_right_2"
		}
	},
	"Smaller_room": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_first.tscn",
		"exits": {
			"back": "Small_pot_right_2",
			"right": "case"
		}
	},
	"case": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_case.tscn",
		"exits": {
			"back": "Smaller_room",
		}
	},
	
	"down_stairs_2": {
		"scene": "res://RoomScenes/Down_stairs_first_from_top.tscn",
		"exits": {
			"forward": "down_stairs_1",
			"back": "Upper_main"
		}
	},
	"down_stairs_1": {
		"scene": "res://RoomScenes/Down_stairs_second_from_top.tscn",
		"exits": {
			"forward": "down_stairs_to_opening",
			"back": "Up_stairs_2"
		}
	},
	"down_stairs_to_opening": {
		"scene": "res://RoomScenes/stairs_to_opening.tscn",
		"exits": {
			"forward": "Opening_first",
			"back": "Upper_main"
		}
	},
}

var current_room = "Opening_first"

func _ready() -> void:
	load_room()

func move(direction):
	var exits = rooms[current_room]["exits"]

	if exits.has(direction):
		current_room = exits[direction]
		load_room()
	else:
		print("No room in that direction")

func load_room():
	var scene_path = rooms[current_room]["scene"]
	
	for c in self.get_children():
		c.queue_free()
	var currnode = load(scene_path)
	var z = currnode.instantiate()
	self.add_child(z)
func fetch_possible_directions():
	return rooms[current_room]["exits"]

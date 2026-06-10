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
			"back": "Upper_middle_forward_final",
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
			"two_boys_painting": "Two_boys",
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
			"back": "Upper_middle_right_back",
			"painting_of_lady": "Upper_middle_lady"
		}
	},
	"Upper_middle_room_opposite": {
		"scene": "res://RoomScenes/upper_middle_room_from_opposite.tscn",
		"exits": {
			"left": "Upper_middle_right_back",
			"right": "Upper_middle_back_1",
			"back": "Upper_middle_forward_final"
		}
	},
	"Upper_middle_lady": {
		"scene": "res://RoomScenes/Upper_middle_lady_painting.tscn",
		"exits": {
			"back": "Upper_middle_forward_2"
		}
	},
	"Upper_middle_right": {
		"scene": "res://RoomScenes/upper_middle_room_right_turn.tscn",
		"exits": {
			"door_im_done_with_naming": "Smaller_room_to_small_room",
			"left": "Upper_middle_forward_2",
			"back": "Upper_middle_right_leaving",
			"right": "Upper_middle_right_back"
		}
	},
	"Upper_middle_right_leaving": {
		"scene": "res://RoomScenes/upper_middle_right_turn_leaving.tscn",
		"exits": {
			"left": "Upper_middle_right_back",
			"right": "Upper_middle_forward_2",
			"back": "Upper_middle_right"
		}
	},
	"Upper_middle_right_back": {
		"scene": "res://RoomScenes/upper_middle_room_backward_two.tscn",
		"exits": {
			"left": "Upper_middle_right",
			"back": "Upper_middle_forward_2",
			"forward": "Upper_middle_room_turned",
			"right": "Upper_middle_right_leaving"
		}
	},
	"Upper_middle_jewels": {
		"scene": "res://RoomScenes/Upper_middle_empty_jewel_box.tscn",
		"exits": {
			"back": "Upper_middle_forward_final"
		}
	},
	"Upper_middle_forward_final": {
		"scene": "res://RoomScenes/Upper_middle_forward_final.tscn",
		"exits": {
			"door_yes": "Big_DR_enter",
			"back": "Upper_middle_room_opposite",
			"boy_painting": "Two_boys",
			"jewel_table": "Upper_middle_jewels"
		}
	},
	
	"Big_DR_enter": {
		"scene": "res://RoomScenes/fancy_room_upper_first.tscn",
		"exits": {
			"gold_statue": "Big_DR_golden_baby",
			"back": "Big_Piano_From_Opposite",
			"right": "Big_DR_vase",
			"left": "Big_DR_Left_Piano"
		}
	},
	"Big_DR_Left_Piano": {
		"scene": "res://RoomScenes/fancy_room_upper_left.tscn",
		"exits": {
			"forward": "Big_Piano_Close",
			"back": "Big_DR_enter",
			"piano_close": "Big_Piano_Close",
			"right": "Big_DR_enter"
		}
	},
	"Big_Piano_Close": {
		"scene": "res://RoomScenes/fancy_room_upper_piano1.tscn",
		"exits": {
			"back": "Big_DR_Left_Piano",
			"piano_closer": "Big_Piano_Closer"
		}
	},
	"Big_Piano_Closer": {
		"scene": "res://RoomScenes/fancy_room_upper_piano2.tscn",
		"exits": {
			"back": "Big_Piano_Close"
		}
	},
	"Big_Piano_From_Opposite": {
		"scene": "res://RoomScenes/fancy_room_piano_different.tscn",
		"exits": {
			"back": "Big_DR_enter",
			"pretty_door": "Upper_middle_room_opposite",
			"piano_uh": "Big_Piano_Close"
		}
	},
	"Big_DR_golden_baby": {
		"scene": "res://RoomScenes/Upper_big_fancy_golden_baby.tscn",
		"exits": {
			"back": "Big_DR_enter",
			"right": "Big_DR_vase"
		}
	},
	"Big_DR_vase": {
		"scene": "res://RoomScenes/fancy_room_vase.tscn",
		"exits": {
			"back": "Big_DR_leaving",
			"right": "Big_DR_right",
			"hateful_door": "Small_pot_room"
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
			"golden_child": "Big_DR_golden_baby",
			"forward": "Big_Piano_From_Opposite"
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
			"back": "Small_room_turned_around"
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
			"back": "Small_pot_room_right",
			"pot_yes_a_pot": "pot"
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
			"forward": "Smaller_room_plate",
			"back": "Smaller_room_door_leave",
			"left": "Smaller_room_left",
		}
	},
	"Smaller_room_left": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_left.tscn",
		"exits": {
			"right": "Smaller_room",
			"back": "Smaller_room_door_leave",
			"forward": "case"
		}
	},
	"Smaller_room_left_turned": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_case_turned.tscn",
		"exits": {
			"back": "case",
			"right": "Smaller_room_door_leave",
			"left": "Smaller_room_plate"
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
	"Smaller_room_plate": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_plate.tscn",
		"exits": {
			"back": "Smaller_room_plate_turn_around"
		}
	},
	"Smaller_room_plate_turn_around": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_turn_from_plate.tscn",
		"exits": {
			"back": "Smaller_room_plate",
			"right": "Smaller_room_left_turned"
		}
	},
	"Smaller_room_door_leave": {
		"scene": "res://RoomScenes/upper_smaller_fancy_room_door_leave.tscn",
		"exits": {
			"back": "Smaller_room",
			"door_the_door": "Upper_main_left_turn_then_around"
		}
	},
}

var current_room = "Opening_first"

func _ready() -> void:
	load_room()

var is_changing_room = false
var is_in_room = false
var _guard_instance = null

const SAFE_ROOMS = [
	# Upper vestibule
	"Down_stairs_2", "Upper_main", "Upper_door_closer", "chest",
	"Upper_main_left_turn", "Leaving_upper_middle", "Up_stairs_2",
	# Lower vestibule
	"Down_stairs_1", "Opening_first", "Opening_right",
	"Up_stairs_1", "Down_stairs_to_opening",
]

func _process(_delta: float) -> void:
	if HeistHUD.minigame_active:
		return
	if current_room in SAFE_ROOMS:
		return
	if Guard.get(Guard.guardRoom).has(current_room):
		if is_in_room:
			return
		is_in_room = true
		var minigame = load("res://Minigames/guardMinigame/guardMinigame.tscn")
		_guard_instance = minigame.instantiate()
		_guard_instance.gameFinished.connect(caught)
		add_child(_guard_instance)
	else:
		if _guard_instance and is_instance_valid(_guard_instance):
			_guard_instance.queue_free()
			_guard_instance = null
		is_in_room = false

func caught():
	_guard_instance = null
	HeistHUD.lose_most_expensive()
	current_room = "Opening_first"
	load_room()


func move(direction):
	if is_changing_room:
		return
	# Player escaped before the timer ran out — dismiss guard silently
	if _guard_instance and is_instance_valid(_guard_instance):
		_guard_instance.queue_free()
		_guard_instance = null
	is_in_room = false
	is_changing_room = true
	var exits = rooms[current_room]["exits"]
	if exits.has(direction):
		current_room = exits[direction]
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

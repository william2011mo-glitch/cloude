extends Node2D

@onready var line: Line2D = $WaveLine

var time := 0.0

# player-controlled values
var frequency := 2.0
var amplitude := 100.0
var noise_amount := 0.23

# hidden target values
var knob1_sweet := 0.0
var knob2_sweet := 0.0
var knob3_sweet := 0.0


const POINTS := 200
const WIDTH := 800


func _ready():
	randomize()

	# generate hidden target positions
	knob1_sweet = randf_range(0.0, 100.0)
	knob2_sweet = randf_range(0.0, 100.0)
	knob3_sweet = randf_range(0.0, 100.0)

	


func _process(delta):
	time += delta

	update_noise()
	update_wave()


func update_noise():
	var k1_error = abs($knob1.value - knob1_sweet)
	var k2_error = abs($knob2.value - knob2_sweet)
	var k3_error = abs($knob3.value - knob3_sweet)
	
	
	if (k3_error + k2_error + k1_error)/100 < 0.1:
		game_won()
	
	# normalize errors into 0–1 range
	noise_amount = (k1_error + k2_error + k3_error) / 300.0

	noise_amount = clamp(noise_amount, 0.0, 1.0)


func update_wave():
	line.clear_points()

	for i in range(POINTS):

		var t = float(i) / float(POINTS - 1)
		var x = t * WIDTH

		# clean sine
		var y = sin(t * frequency * TAU + time) * amplitude

		# noise
		var noise = (randf() - 0.5) * noise_amount * amplitude

		line.add_point(Vector2(x, y + noise))



func game_won():
	print("Wow you one")



func _on_knob_3_value_changed(value: float) -> void:
	update_noise()


func _on_knob_2_value_changed(value: float) -> void:
	update_noise()


func _on_knob_1_value_changed(value: float) -> void:
	update_noise()

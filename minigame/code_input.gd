extends LineEdit

const MAX_DIGITS := 4

var code := randi_range(0, 9999)

func _ready():
	text_changed.connect(_on_text_changed)


func _on_text_changed(new_text):

	var filtered := ""

	for c in new_text:
		if c in "0123456789":
			filtered += c

	# limit length
	filtered = filtered.substr(0, MAX_DIGITS)

	if filtered != new_text:
		text = filtered
		caret_column = text.length()






func _on_text_submitted(new_text: String) -> void:
	if new_text.length() < 4:
		$"../RichTextLabel".text = "Enter a valid code"
	else:
		var code_string = str(code).pad_zeros(4)
		
		
		var actual1 = int(code_string[0])
		var actual2 = int(code_string[1])
		var actual3 = int(code_string[2])
		var actual4 = int(code_string[3])
		
		
		var err = abs(actual1 - int(new_text[0])) + abs(actual2 - int(new_text[1])) + abs(actual3 - int(new_text[2])) + abs(actual4 - int(new_text[3]))
		if err == 0:
			game_won()
		
		$"../RichTextLabel".text = "Error: " + str(err)
		
	
	
func game_won():
	print("wow u 1")
	

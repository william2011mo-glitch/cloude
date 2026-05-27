extends CanvasLayer

var attempts = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_checik_pressed() -> void:
	var codeSq = []
	var answerSq = []
	
	for c in get_tree().get_nodes_in_group('codeSquares'):
		codeSq.append(c.currentColorI)
	for a in get_tree().get_nodes_in_group('answerSquares'):
		answerSq.append(a.currentColorI)
	if(codeSq == answerSq):
		$manager/result.text = 'Correct'
	else:
		$manager/result.text = 'Incorrect'

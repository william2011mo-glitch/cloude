extends Control


# UI references
var list_input:    LineEdit
var find_input:    LineEdit
var replace_input: LineEdit
var code_input:    TextEdit
var result_label:  Label
var test_button:   Button


func _ready():
	build_ui()


func build_ui():
	# Root margin container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "replaceAll() Solution Checker"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Method signature display
	var sig_label = Label.new()
	sig_label.text = "Method signature:"
	vbox.add_child(sig_label)

	var sig_box = PanelContainer.new()
	vbox.add_child(sig_box)

	var sig_text = Label.new()
	sig_text.text = "public static void replaceAll(ArrayList<String> list, String findMe, String replaceWith)"
	sig_text.add_theme_font_size_override("font_size", 14)
	sig_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	sig_box.add_child(sig_text)

	# Variable name row
	var var_label = Label.new()
	var_label.text = "Variable names used in your solution:"
	vbox.add_child(var_label)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox)

	list_input    = _make_line_edit("List name",    "list",        120)
	find_input    = _make_line_edit("Find name",    "findMe",      120)
	replace_input = _make_line_edit("Replace name", "replaceWith", 140)

	for field in [list_input, find_input, replace_input]:
		hbox.add_child(field)

	# Code input
	var code_label = Label.new()
	code_label.text = "Paste your solution here:"
	vbox.add_child(code_label)

	code_input = TextEdit.new()
	code_input.custom_minimum_size = Vector2(0, 260)
	code_input.placeholder_text = "e.g.\nfor (int i = 0; i < list.size(); i++) {\n    if (list.get(i).equals(findMe)) {\n        list.set(i, replaceWith);\n    }\n}"
	vbox.add_child(code_input)

	# Buttons
	var btn_row = HBoxContainer.new()
	vbox.add_child(btn_row)

	test_button = Button.new()
	test_button.text = "Check Solution"
	test_button.pressed.connect(_on_check_pressed)
	btn_row.add_child(test_button)

	var clear_btn = Button.new()
	clear_btn.text = "Clear"
	clear_btn.pressed.connect(_on_clear_pressed)
	btn_row.add_child(clear_btn)

	# Result label
	result_label = Label.new()
	result_label.text = ""
	result_label.add_theme_font_size_override("font_size", 16)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)


func _make_line_edit(placeholder: String, default_text: String, min_width: int) -> LineEdit:
	var field = LineEdit.new()
	field.placeholder_text = placeholder
	field.text = default_text
	field.custom_minimum_size = Vector2(min_width, 0)
	return field


func _on_check_pressed():
	var raw          = code_input.text
	var list_name    = list_input.text.strip_edges()
	var find_name    = find_input.text.strip_edges()
	var replace_name = replace_input.text.strip_edges()

	if raw.strip_edges() == "":
		result_label.text = "Please enter your solution."
		result_label.modulate = Color.ORANGE
		return

	if list_name == "" or find_name == "" or replace_name == "":
		result_label.text = "Please fill in all three variable name fields."
		result_label.modulate = Color.ORANGE
		return

	var result = check_replace_all_solution(raw, list_name, find_name, replace_name)

	if result.begins_with("Correct"):
		result_label.modulate = Color.GREEN
	else:
		result_label.modulate = Color.RED

	result_label.text = result


func _on_clear_pressed():
	code_input.text = ""
	result_label.text = ""


# ─── Checker logic ─────────────────────────────────────────────────────────────

func strip(s: String) -> String:
	return s.replace(" ", "").replace("\n", "").replace("\t", "").replace("\r", "")


func check_replace_all_solution(raw: String, list_name: String, find_name: String, replace_name: String) -> String:
	var s = strip(raw)

	var size_check_paren = "<" + list_name + ".size())"
	var size_check_semi  = "<" + list_name + ".size();"
	var get_call         = list_name + ".get("
	var equals_call      = ").equals(" + find_name + ")"
	var set_call         = list_name + ".set("
	var set_value        = "," + replace_name + ")"

	# indexOf checked first — its while( would match the while branch otherwise
	var indexOf_marker = "=" + list_name + ".indexOf(" + find_name + "))!=-1)"
	var is_index_of = (
		s.contains("while((") and
		s.contains(indexOf_marker) and
		s.contains(set_call) and
		s.contains(set_value)
	)

	var is_while = (
		not is_index_of and
		s.contains("while(") and
		s.contains(size_check_paren) and
		s.contains(get_call) and
		s.contains(equals_call) and
		s.contains(set_call) and
		s.contains(set_value) and
		(s.contains("++") or s.contains("+=1"))
	)

	# for loop: size() is followed by ; not )
	var is_standard = (
		not is_index_of and
		not is_while and
		s.contains("for(int") and
		s.contains(size_check_semi) and
		s.contains(get_call) and
		s.contains(equals_call) and
		s.contains(set_call) and
		s.contains(set_value)
	)

	var recursive_call = list_name + "," + find_name + "," + replace_name + ","
	var is_recursive = (
		not is_standard and
		not is_while and
		not is_index_of and
		s.contains(list_name + ".size())return;") and
		s.contains(get_call) and
		s.contains(equals_call) and
		s.contains(set_call) and
		s.contains(set_value) and
		s.contains(recursive_call)
	)

	if is_standard:
		return "Correct! Standard for loop solution."
	elif is_while:
		return "Correct! While loop solution."
	elif is_index_of:
		return "Correct! indexOf loop solution."
	elif is_recursive:
		return "Correct! Recursive solution."
	else:
		return "Incorrect. Try again."

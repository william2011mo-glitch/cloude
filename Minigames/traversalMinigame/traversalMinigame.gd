extends Control

signal game_finished(won: bool, score: int)

# UI references
var list_input:    LineEdit
var find_input:    LineEdit
var replace_input: LineEdit
var code_input:    TextEdit
var result_label:  Label
var test_button:   Button

var _start_panel: Control
var _state: String = "start"


func _ready():
	build_ui()
	_add_start_panel()


func _add_start_panel() -> void:
	var vp := get_viewport().get_visible_rect().size
	_start_panel = Control.new()
	_start_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_start_panel)

	var sp_bg := ColorRect.new()
	sp_bg.color = Color(0.10, 0.10, 0.12, 0.92)
	sp_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sp_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_panel.add_child(sp_bg)

	var sp_box := VBoxContainer.new()
	sp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_box.add_theme_constant_override("separation", 22)
	sp_box.custom_minimum_size = Vector2(700, 0)
	sp_box.position = Vector2(vp.x / 2.0 - 350.0, vp.y / 2.0 - 180.0)
	_start_panel.add_child(sp_box)

	var sp_title := Label.new()
	sp_title.text = "Array Traversal Challenge"
	sp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_title.add_theme_font_size_override("font_size", 48)
	sp_box.add_child(sp_title)

	var sp_sub := Label.new()
	sp_sub.text = "Press Space to start"
	sp_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_sub.add_theme_font_size_override("font_size", 28)
	sp_sub.modulate = Color(0.78, 0.78, 0.78)
	sp_box.add_child(sp_sub)

	var sp_how := Label.new()
	sp_how.text = "Write a Java solution for replaceAll(ArrayList list, String findMe, String replaceWith).\nTraverse the list and replace every string that matches findMe with replaceWith.\nSubmit your solution to crack the case open."
	sp_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_how.add_theme_font_size_override("font_size", 19)
	sp_how.modulate = Color(0.60, 0.60, 0.60)
	sp_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_how.custom_minimum_size = Vector2(700, 0)
	sp_box.add_child(sp_how)


func _unhandled_input(event: InputEvent) -> void:
	if _state == "start" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_start_panel.visible = false
		_state = "playing"
		get_viewport().set_input_as_handled()


func build_ui():
	# Dark background so content is readable over the room
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.10, 0.93)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	# CenterContainer fills screen and auto-centers the panel
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1100, 0)
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top",    40)
	margin.add_theme_constant_override("margin_left",   50)
	margin.add_theme_constant_override("margin_right",  50)
	margin.add_theme_constant_override("margin_bottom", 40)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Title
	var title = Label.new()
	title.text = "replaceAll() Solution Checker"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)

	# Method signature display
	var sig_label = Label.new()
	sig_label.text = "Method signature:"
	sig_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(sig_label)

	var sig_box = PanelContainer.new()
	vbox.add_child(sig_box)

	var sig_text = Label.new()
	sig_text.text = "public static void replaceAll(ArrayList<String> list, String findMe, String replaceWith)"
	sig_text.add_theme_font_size_override("font_size", 26)
	sig_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sig_box.add_child(sig_text)

	# Variable name row
	var var_label = Label.new()
	var_label.text = "Variable names used in your solution:"
	var_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(var_label)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)

	list_input    = _make_line_edit("List name",    "list",        200)
	find_input    = _make_line_edit("Find name",    "findMe",      200)
	replace_input = _make_line_edit("Replace name", "replaceWith", 240)

	for field in [list_input, find_input, replace_input]:
		field.add_theme_font_size_override("font_size", 26)
		hbox.add_child(field)
		field.editable = false

	# Code input
	var code_label = Label.new()
	code_label.text = "Paste your solution here:"
	code_label.add_theme_font_size_override("font_size", 28)
	vbox.add_child(code_label)

	code_input = TextEdit.new()
	code_input.custom_minimum_size = Vector2(0, 220)
	code_input.placeholder_text = "// write your Java solution here"
	code_input.add_theme_font_size_override("font_size", 26)
	vbox.add_child(code_input)

	# Buttons
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	test_button = Button.new()
	test_button.text = "Check Solution"
	test_button.custom_minimum_size = Vector2(260, 60)
	test_button.add_theme_font_size_override("font_size", 28)
	test_button.pressed.connect(_on_check_pressed)
	btn_row.add_child(test_button)

	var clear_btn = Button.new()
	clear_btn.text = "Clear"
	clear_btn.custom_minimum_size = Vector2(160, 60)
	clear_btn.add_theme_font_size_override("font_size", 28)
	clear_btn.pressed.connect(_on_clear_pressed)
	btn_row.add_child(clear_btn)

	var give_up_btn = Button.new()
	give_up_btn.text = "Give Up"
	give_up_btn.custom_minimum_size = Vector2(160, 60)
	give_up_btn.add_theme_font_size_override("font_size", 28)
	give_up_btn.pressed.connect(_on_give_up_pressed)
	btn_row.add_child(give_up_btn)

	# Result label
	result_label = Label.new()
	result_label.text = ""
	result_label.add_theme_font_size_override("font_size", 30)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(result_label)


func _make_line_edit(placeholder: String, default_text: String, min_width: int) -> LineEdit:
	var field = LineEdit.new()
	field.placeholder_text = placeholder
	field.text = default_text
	field.custom_minimum_size = Vector2(min_width, 54)
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
		result_label.text = result
		_show_end_overlay(true)
	else:
		result_label.modulate = Color.RED
		result_label.text = result


func _on_clear_pressed():
	code_input.text = ""
	result_label.text = ""


func _on_give_up_pressed() -> void:
	_show_end_overlay(false)


func _show_end_overlay(win: bool) -> void:
	var vp := get_viewport().get_visible_rect().size
	var ep := Control.new()
	ep.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ep)

	var ep_bg := ColorRect.new()
	ep_bg.color = Color(0, 0, 0, 0.75)
	ep_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ep_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	ep.add_child(ep_bg)

	var ep_lbl := Label.new()
	ep_lbl.text = "Correct solution!\nThe case clicks open." if win else "You gave up.\nThe jewel stays put."
	ep_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ep_lbl.add_theme_font_size_override("font_size", 52)
	ep_lbl.add_theme_color_override("font_color", Color(0.20, 0.95, 0.44) if win else Color(0.95, 0.20, 0.20))
	ep_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ep_lbl.custom_minimum_size = Vector2(700, 0)
	ep_lbl.position = Vector2(vp.x / 2.0 - 350.0, vp.y / 2.0 - 80.0)
	ep.add_child(ep_lbl)

	emit_signal("game_finished", win, 0)
	await get_tree().create_timer(2.5).timeout
	queue_free()


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

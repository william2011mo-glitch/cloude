extends CanvasLayer

const COIN_TEXTURE = preload("res://BW Museum Photos PNG/Coin.png")
const DIALOGUE_TEXTURE = preload("res://BW Museum Photos PNG/DialogueBoxCloude.png")
const CAUGHT_TEXTURE = preload("res://BW Museum Photos PNG/DialogueBoxYou.png")

const COIN_W := 70.0
const COIN_H := 100.0

var stolen_items: Array[String] = []
var _item_data: Array = []   # Array of {name, coins}
var _coin_nodes: Array = []
var _popup: Control = null
var minigame_active: bool = false
var attempted_items: Dictionary = {}

const MUSEUM_TIME := 480.0  # 8 minutes
var _time_left: float = MUSEUM_TIME
var _timer_running: bool = false  # started explicitly via start_timer()
var _timer_label: Label = null
var _timer_bg: ColorRect = null
var _leave_btn: Button = null
var _confirm_dialog: Control = null
var _end_screen: Control = null


func _ready() -> void:
	_build_timer_display()
	_build_leave_button()


func start_timer() -> void:
	_timer_running = true


func _process(delta: float) -> void:
	if not _timer_running:
		return
	_time_left -= delta
	_update_timer_label()
	if _time_left <= 0.0:
		_time_left = 0.0
		_timer_running = false
		_show_end_screen(false)


func _build_timer_display() -> void:
	_timer_bg = ColorRect.new()
	_timer_bg.color = Color(0, 0, 0, 0.55)
	_timer_bg.position = Vector2(16.0, 16.0)
	_timer_bg.size = Vector2(180.0, 48.0)
	_timer_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_timer_bg)

	_timer_label = Label.new()
	_timer_label.position = Vector2(20.0, 18.0)
	_timer_label.size = Vector2(172.0, 44.0)
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_label.add_theme_font_size_override("font_size", 30)
	add_child(_timer_label)
	_update_timer_label()


func _build_leave_button() -> void:
	_leave_btn = Button.new()
	_leave_btn.text = "Leave Museum"
	_leave_btn.position = Vector2(1920.0 - 268.0, 14.0)
	_leave_btn.size = Vector2(254.0, 50.0)
	_leave_btn.add_theme_font_size_override("font_size", 24)
	_leave_btn.pressed.connect(_on_leave_pressed)
	add_child(_leave_btn)


func _update_timer_label() -> void:
	if not is_instance_valid(_timer_label):
		return
	var mins := int(_time_left) / 60
	var secs := int(_time_left) % 60
	_timer_label.text = "⏱  %d:%02d" % [mins, secs]
	if _time_left <= 60.0:
		_timer_label.modulate = Color(1.0, 0.25, 0.25)
		_timer_bg.color = Color(0.35, 0.0, 0.0, 0.80)
	elif _time_left <= 120.0:
		_timer_label.modulate = Color(1.0, 0.78, 0.15)
		_timer_bg.color = Color(0.22, 0.15, 0.0, 0.75)
	else:
		_timer_label.modulate = Color(1.0, 1.0, 1.0)
		_timer_bg.color = Color(0.0, 0.0, 0.0, 0.55)


# ── Leave confirmation ────────────────────────────────────────────────────────

func _on_leave_pressed() -> void:
	if (_end_screen and is_instance_valid(_end_screen)): return
	if (_confirm_dialog and is_instance_valid(_confirm_dialog)): return
	_show_leave_confirm()


func _show_leave_confirm() -> void:
	_confirm_dialog = Control.new()
	_confirm_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_confirm_dialog)

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_dialog.add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(800, 0)
	panel.position = Vector2(960.0 - 400.0, 340.0)
	_confirm_dialog.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top",    44)
	margin.add_theme_constant_override("margin_left",   54)
	margin.add_theme_constant_override("margin_right",  54)
	margin.add_theme_constant_override("margin_bottom", 44)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 28)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Leave the museum?"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 48)
	vbox.add_child(lbl)

	var sub := Label.new()
	sub.text = "You'll escape with whatever you've collected so far."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 26)
	sub.modulate = Color(0.72, 0.72, 0.72)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(640, 0)
	vbox.add_child(sub)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 28)
	vbox.add_child(btn_row)

	var yes_btn := Button.new()
	yes_btn.text = "Yes, leave now"
	yes_btn.custom_minimum_size = Vector2(230, 62)
	yes_btn.add_theme_font_size_override("font_size", 26)
	yes_btn.pressed.connect(func():
		_confirm_dialog.queue_free()
		_confirm_dialog = null
		_timer_running = false
		_show_end_screen(true)
	)
	btn_row.add_child(yes_btn)

	var no_btn := Button.new()
	no_btn.text = "No, I need more time"
	no_btn.custom_minimum_size = Vector2(270, 62)
	no_btn.add_theme_font_size_override("font_size", 26)
	no_btn.pressed.connect(func():
		_confirm_dialog.queue_free()
		_confirm_dialog = null
	)
	btn_row.add_child(no_btn)

	_confirm_dialog.modulate.a = 0.0
	create_tween().tween_property(_confirm_dialog, "modulate:a", 1.0, 0.25)


# ── End screen ────────────────────────────────────────────────────────────────

func _show_end_screen(escaped: bool) -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
		_popup = null

	_end_screen = Control.new()
	_end_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_end_screen)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_end_screen.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_end_screen.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_top",    54)
	margin.add_theme_constant_override("margin_left",   64)
	margin.add_theme_constant_override("margin_right",  64)
	margin.add_theme_constant_override("margin_bottom", 54)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Title
	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 80)
	if escaped:
		title.text = "You Escaped!"
		title.add_theme_color_override("font_color", Color(0.28, 1.0, 0.50))
	else:
		title.text = "Caught!"
		title.add_theme_color_override("font_color", Color(1.0, 0.28, 0.28))
	vbox.add_child(title)

	# Subtitle
	var sub := Label.new()
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 26)
	sub.modulate = Color(0.68, 0.68, 0.68)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(680, 0)
	if escaped:
		sub.text = "You slipped out undetected. Not bad for a night's work."
	else:
		sub.text = "You took too long — the guards finally noticed you."
	vbox.add_child(sub)

	var hr := HSeparator.new()
	hr.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(hr)

	# Haul header
	var haul_hdr := Label.new()
	haul_hdr.text = "Your haul:" if escaped else "You managed to pocket:"
	haul_hdr.add_theme_font_size_override("font_size", 34)
	haul_hdr.add_theme_color_override("font_color", Color(0.95, 0.88, 0.58))
	vbox.add_child(haul_hdr)

	var total_coins := 0
	if _item_data.is_empty():
		var none_lbl := Label.new()
		none_lbl.text = "    Nothing. You leave empty-handed."
		none_lbl.add_theme_font_size_override("font_size", 28)
		none_lbl.modulate = Color(0.50, 0.50, 0.50)
		vbox.add_child(none_lbl)
	else:
		for item in _item_data:
			total_coins += item.coins
			var coin_str := "1 coin" if item.coins == 1 else "%d coins" % item.coins
			var row := Label.new()
			row.text = "    •  %s  —  %s" % [item.name, coin_str]
			row.add_theme_font_size_override("font_size", 28)
			vbox.add_child(row)

	var hr2 := HSeparator.new()
	vbox.add_child(hr2)

	# Total
	var total_lbl := Label.new()
	total_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_lbl.add_theme_font_size_override("font_size", 44)
	total_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.28))
	total_lbl.text = "Total:  %d %s" % [total_coins, "coin" if total_coins == 1 else "coins"]
	vbox.add_child(total_lbl)

	# Play Again
	var btn_wrap := HBoxContainer.new()
	btn_wrap.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_wrap)

	var again_btn := Button.new()
	again_btn.text = "Play Again"
	again_btn.custom_minimum_size = Vector2(220, 62)
	again_btn.add_theme_font_size_override("font_size", 30)
	again_btn.pressed.connect(_on_play_again)
	btn_wrap.add_child(again_btn)

	_end_screen.modulate.a = 0.0
	create_tween().tween_property(_end_screen, "modulate:a", 1.0, 1.2)


func _on_play_again() -> void:
	stolen_items.clear()
	_item_data.clear()
	for c in _coin_nodes:
		if is_instance_valid(c): c.queue_free()
	_coin_nodes.clear()
	attempted_items.clear()
	_time_left = MUSEUM_TIME
	_timer_running = false  # will restart when game.gd calls start_timer()
	if _end_screen and is_instance_valid(_end_screen):
		_end_screen.queue_free()
		_end_screen = null
	_update_timer_label()
	get_tree().reload_current_scene()

func mark_attempted(key: String) -> void:
	attempted_items[key] = true

func has_attempted(key: String) -> bool:
	return attempted_items.has(key)

func show_already_tried_popup() -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
	_popup = Control.new()
	_popup.position = Vector2(510.0, 580.0)
	_popup.size = Vector2(900.0, 630.0)
	add_child(_popup)

	var dark := ColorRect.new()
	dark.color = Color(0, 0, 0, 0.55)
	dark.layout_mode = 0
	dark.offset_left   = 10.0
	dark.offset_top    = 140.0
	dark.offset_right  = 890.0
	dark.offset_bottom = 440.0
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(dark)

	var bg := TextureRect.new()
	bg.texture = CAUGHT_TEXTURE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(bg)

	var lbl := Label.new()
	lbl.text = "Looks like I've already tried to steal this...\nI'll go find something else."
	lbl.position = Vector2(130.0, 150.0)
	lbl.size = Vector2(640.0, 300.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 38)
	_popup.add_child(lbl)

	_popup.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_popup, "modulate:a", 1.0, 0.4)
	tw.tween_interval(3.0)
	tw.tween_property(_popup, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func():
		if is_instance_valid(_popup):
			_popup.queue_free()
		_popup = null
	)

func steal_item(item_name: String, coins: int = 1) -> void:
	stolen_items.append(item_name)
	_item_data.append({"name": item_name, "coins": coins})
	_spawn_coin()
	_show_popup(item_name, coins, false)

func lose_most_expensive() -> void:
	if _item_data.is_empty():
		_show_caught_popup("nothing — you got away clean!", 0)
		return
	var max_idx := 0
	for i in _item_data.size():
		if _item_data[i].coins > _item_data[max_idx].coins:
			max_idx = i
	var lost: Dictionary = _item_data[max_idx]
	_item_data.remove_at(max_idx)
	stolen_items.erase(lost.name)
	if _coin_nodes.size() > 0:
		var last_coin = _coin_nodes.pop_back()
		if is_instance_valid(last_coin):
			last_coin.queue_free()
	_show_caught_popup(lost.name, lost.coins)

func _spawn_coin() -> void:
	var idx := _coin_nodes.size()
	var coin_crop := AtlasTexture.new()
	coin_crop.atlas = COIN_TEXTURE
	coin_crop.region = Rect2(426, 907, 792, 305)
	var tr := TextureRect.new()
	tr.texture = coin_crop
	tr.layout_mode = 0
	# each coin is 160×62, stacked 30px higher than the last
	tr.offset_left   = 1920.0 - 200.0 - 20.0
	tr.offset_top    = 1080.0 - 72.0  - 20.0 - idx * 15.0
	tr.offset_right  = tr.offset_left  + 110.0
	tr.offset_bottom = tr.offset_top   + 42.0
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(tr)
	_coin_nodes.append(tr)
	tr.scale = Vector2(0.1, 0.1)
	var tw := create_tween()
	tw.tween_property(tr, "scale", Vector2(1.0, 1.0), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)






func _show_popup(item_name: String, coins: int, caught: bool) -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
	_popup = Control.new()
	_popup.position = Vector2(510.0, 580.0)
	_popup.size = Vector2(900.0, 630.0)
	add_child(_popup)

	var dark := ColorRect.new()
	dark.color = Color(0, 0, 0, 0.55)
	dark.layout_mode = 0
	dark.offset_left   = 10.0
	dark.offset_top    = 140.0
	dark.offset_right  = 890.0
	dark.offset_bottom = 440.0
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(dark)

	var bg := TextureRect.new()
	bg.texture = DIALOGUE_TEXTURE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(bg)

	var lbl := Label.new()
	lbl.text = "Congrats! You were able to steal\n%s!" % item_name
	lbl.position = Vector2(130.0, 150.0)
	lbl.size = Vector2(640.0, 300.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 38)
	_popup.add_child(lbl)

	var coin_lbl := Label.new()
	coin_lbl.text = "+1 coin"
	coin_lbl.layout_mode = 0
	coin_lbl.position = Vector2(140.0, 370.0)
	coin_lbl.add_theme_font_size_override("font_size", 30)
	_popup.add_child(coin_lbl)

	_popup.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_popup, "modulate:a", 1.0, 0.4)
	tw.tween_interval(3.5)
	tw.tween_property(_popup, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func():
		if is_instance_valid(_popup):
			_popup.queue_free()
		_popup = null
	)

func _show_caught_popup(lost_item: String, coins: int) -> void:
	if _popup and is_instance_valid(_popup):
		_popup.queue_free()
	_popup = Control.new()
	_popup.position = Vector2(510.0, 580.0)
	_popup.size = Vector2(900.0, 630.0)
	add_child(_popup)

	var dark := ColorRect.new()
	dark.color = Color(0, 0, 0, 0.55)
	dark.layout_mode = 0
	dark.offset_left   = 10.0
	dark.offset_top    = 140.0
	dark.offset_right  = 890.0
	dark.offset_bottom = 440.0
	dark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(dark)

	var bg := TextureRect.new()
	bg.texture = CAUGHT_TEXTURE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.add_child(bg)

	var lbl := Label.new()
	if coins > 0:
		lbl.text = "You got caught!\nYou lost\n%s." % lost_item
	else:
		lbl.text = "You got caught!\nYou had nothing to lose."
	lbl.position = Vector2(130.0, 150.0)
	lbl.size = Vector2(640.0, 300.0)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 38)
	_popup.add_child(lbl)

	_popup.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_popup, "modulate:a", 1.0, 0.4)
	tw.tween_interval(3.5)
	tw.tween_property(_popup, "modulate:a", 0.0, 0.4)
	tw.tween_callback(func():
		if is_instance_valid(_popup):
			_popup.queue_free()
		_popup = null
	)

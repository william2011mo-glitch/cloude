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

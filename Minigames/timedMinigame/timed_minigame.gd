extends CanvasLayer
<<<<<<< HEAD
signal game_finished(won:bool, score:int);
=======

signal game_finished(won: bool, score: int)

>>>>>>> 6eb8fc09f34396a2141564656eb21a0751d3a47a
@onready var background : ColorRect = $Control/Background
@onready var time1 : ColorRect = $Control/Time1
@onready var time2 : ColorRect = $Control/Time2
@onready var player : ColorRect = $Control/Player

const BAR_Y        : float = 550.0   # Vertical centre of the bar on screen
const BAR_X        : float = 230.0   # Left edge of the bar
const BAR_WIDTH    : float = 1460.0  # Total bar length in pixels
const BAR_HEIGHT   : float = 50.0    # Bar thickness

const ZONE_WIDTH   : float = 80.0    # Width of each target zone (time1 / time2)
const PLAYER_WIDTH : float = 8.0     # Width of the moving pointer

var _speed        : float = 600.0   # Pixels per second

var _pos        : float = 0.0   # Pointer position relative to bar left (0 → BAR_WIDTH)
var _direction  : float = 1.0   # +1 = right, -1 = left
var _active     : bool  = false
var _hit_zone1  : bool  = false
var _hit_zone2  : bool  = false
var _state        : String = "start"
var _start_panel  : Control

const COLOR_ZONE_DEFAULT : Color = Color(0.9, 0.75, 0.1)  
const COLOR_ZONE_HIT     : Color = Color(0.2, 0.85, 0.3)   
const COLOR_ZONE_MISS    : Color = Color(0.85, 0.2, 0.2)   


func _ready() -> void:
	# ── Background bar ──
	background.color    = Color(0.15, 0.15, 0.15)
	background.size     = Vector2(BAR_WIDTH, BAR_HEIGHT)
	background.position = Vector2(BAR_X, BAR_Y)

	# ── Zone 1 (left target) ──
	time1.color    = COLOR_ZONE_DEFAULT
	time1.size     = Vector2(ZONE_WIDTH, BAR_HEIGHT)
	var pos1 = randf();
	if(pos1>0.95):
		pos1-=0.05;
	time1.position = Vector2(BAR_X + BAR_WIDTH * pos1, BAR_Y)

	# ── Zone 2 (right target) ──
	time2.color    = COLOR_ZONE_DEFAULT
	time2.size     = Vector2(ZONE_WIDTH, BAR_HEIGHT)
	var pos2 = randf()
	while(abs(pos2-pos1)<0.05):
		pos2 = randf()
		if(pos2>0.95):
			pos2-=0.05;
	time2.position = Vector2(BAR_X + BAR_WIDTH * pos2, BAR_Y)

	# ── Player pointer ──
	player.color    = Color(0.95, 0.1, 0.1)
	player.size     = Vector2(PLAYER_WIDTH, BAR_HEIGHT)
	player.position = Vector2(BAR_X, BAR_Y)

	# _active stays false until start panel is dismissed
	var vp := get_viewport().get_visible_rect().size
	_start_panel = Control.new()
	var sp := _start_panel
	sp.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(sp)

	var sp_bg := ColorRect.new()
	sp_bg.color = Color(0, 0, 0, 0.82)
	sp_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sp_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	sp.add_child(sp_bg)

	var sp_box := VBoxContainer.new()
	sp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	sp_box.add_theme_constant_override("separation", 22)
	sp_box.position = Vector2(vp.x / 2.0 - 300.0, vp.y / 2.0 - 150.0)
	sp_box.custom_minimum_size = Vector2(600, 0)
	sp.add_child(sp_box)

	var sp_title := Label.new()
	sp_title.text = "Crack the Lock"
	sp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_title.add_theme_font_size_override("font_size", 58)
	sp_box.add_child(sp_title)

	var sp_sub := Label.new()
	sp_sub.text = "Press Space to start"
	sp_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_sub.add_theme_font_size_override("font_size", 28)
	sp_sub.modulate = Color(0.78, 0.78, 0.78)
	sp_box.add_child(sp_sub)

	var sp_how := Label.new()
	sp_how.text = "A pointer sweeps across the bar. Click (or Space) when it lands on each yellow zone. Miss a zone and the lock jams."
	sp_how.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sp_how.add_theme_font_size_override("font_size", 21)
	sp_how.modulate = Color(0.60, 0.60, 0.60)
	sp_how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sp_how.custom_minimum_size = Vector2(600, 0)
	sp_box.add_child(sp_how)

	sp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if not _active:
		return

	_pos += _direction * _speed * delta

	if _pos >= BAR_WIDTH - PLAYER_WIDTH:
		_pos = BAR_WIDTH - PLAYER_WIDTH
		_direction = -1.0
		if(_speed<800):
			_speed+=50;
	elif _pos <= 0.0:
		_pos = 0.0
		_direction = 1.0
		if(_speed<800):
			_speed+=50;

	player.position.x = BAR_X + _pos


func _unhandled_input(event: InputEvent) -> void:
	if _state == "start" and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if _start_panel and is_instance_valid(_start_panel):
			_start_panel.queue_free()
		_state = "playing"
		_active = true
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if not _active or _state != "playing":
		return

	var triggered := false

	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed and not event.echo:
			triggered = true
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			triggered = true

	if not triggered:
		return

	# Check each unhit zone
	if not _hit_zone1 and _is_in_zone(time1):
		_hit_zone1 = true
		time1.color = COLOR_ZONE_HIT
	elif not _hit_zone2 and _is_in_zone(time2):
		_hit_zone2 = true
		time2.color = COLOR_ZONE_HIT
	else:
		if not _hit_zone1:
			time1.color = COLOR_ZONE_MISS
		if not _hit_zone2:
			time2.color = COLOR_ZONE_MISS
		_active = false
<<<<<<< HEAD
		
		queue_free()
		return
	if _hit_zone1 and _hit_zone2:
		_active = false
		emit_signal("game_finished", true, 0);
		queue_free()
=======
		_show_end_overlay(false)
		return
	if _hit_zone1 and _hit_zone2:
		_active = false
		_show_end_overlay(true)
>>>>>>> 6eb8fc09f34396a2141564656eb21a0751d3a47a


func _is_in_zone(zone: ColorRect) -> bool:
	var player_left  : float = player.position.x
	var player_right : float = player_left + PLAYER_WIDTH
	var zone_left    : float = zone.position.x
	var zone_right   : float = zone_left + ZONE_WIDTH
	return player_right > zone_left and player_left < zone_right

func _show_end_overlay(win: bool) -> void:
	var vp := get_viewport().get_visible_rect().size
	var ep := Control.new()
	ep.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ep)

	var ep_bg := ColorRect.new()
	ep_bg.color = Color(0, 0, 0, 0.70)
	ep_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ep_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ep.add_child(ep_bg)

	var ep_lbl := Label.new()
	ep_lbl.text = "Lock cracked!\nThe diamond is yours." if win else "Lock jammed.\nBetter luck next time."
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

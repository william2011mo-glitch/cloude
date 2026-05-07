extends Node2D

# --- Challenge definition ---
const CHALLENGE_PROMPT = "Write a function traverse(arr) that returns all elements front-to-back."

var test_cases := [
	{ "input": [1, 2, 3],          "expected": [1, 2, 3]          },
	{ "input": [10, 20, 30, 40],   "expected": [10, 20, 30, 40]   },
	{ "input": [],                 "expected": []                  },
	{ "input": ["a", "b", "c"],    "expected": ["a", "b", "c"]    },
	{ "input": [7],                "expected": [7]                 },
]

# --- Node refs ---
@onready var code_editor    : TextEdit   = $VBoxContainer/CodeEditor
@onready var run_button     : Button     = $VBoxContainer/RunButton
@onready var results_box    : VBoxContainer = $VBoxContainer/ResultsContainer
@onready var challenge_label: Label      = $VBoxContainer/ChallengeLabel

func _ready() -> void:
	challenge_label.text = CHALLENGE_PROMPT
	run_button.pressed.connect(_on_run_pressed)
	code_editor.text = "func traverse(arr: Array) -> Array:\n\tpass\n"
	# TextEdit grows to fill leftover height
	code_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Everything else stays its natural height
	challenge_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	run_button.size_flags_vertical      = Control.SIZE_SHRINK_BEGIN
	results_box.size_flags_vertical     = Control.SIZE_SHRINK_BEGIN

func _on_run_pressed() -> void:
	var player_code: String = code_editor.text
	_run_tests(player_code)

# -------------------------------------------------------------------
# Core execution engine
# -------------------------------------------------------------------
func _run_tests(player_code: String) -> void:
	# Clear old results
	for child in results_box.get_children():
		child.queue_free()

	# Wrap the player's function(s) in a class
	var full_source := """
extends RefCounted

%s
""" % player_code

	# Compile it
	var script := GDScript.new()
	script.source_code = full_source
	var compile_error := script.reload()

	if compile_error != OK:
		_show_result("Syntax error — check your code.", false)
		return

	# Instantiate so we can call methods
	var instance = script.new()

	# Run each test case
	var passed := 0
	for i in test_cases.size():
		var tc: Dictionary = test_cases[i]
		var result = _call_safe(instance, "traverse", [tc["input"].duplicate()])
		var ok: bool = (result == tc["expected"])
		if ok:
			passed += 1
		_show_result(
			"Test %d: traverse(%s) → %s  %s" % [
				i + 1,
				str(tc["input"]),
				str(result) if result != null else "ERROR",
				"✓" if ok else "✗  (expected %s)" % str(tc["expected"])
			],
			ok
		)

	# Summary
	var all_passed := passed == test_cases.size()
	_show_result(
		"%d / %d passed%s" % [passed, test_cases.size(), "  — vault unlocked!" if all_passed else ""],
		all_passed
	)
	if all_passed:
		_on_challenge_complete()

# Safely call a method that might not exist or might throw
func _call_safe(instance: Object, method: String, args: Array) -> Variant:
	if not instance.has_method(method):
		return null
	return instance.callv(method, args)

# -------------------------------------------------------------------
# UI helpers
# -------------------------------------------------------------------
func _show_result(text: String, success: bool) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(
		"font_color",
		Color.GREEN if success else Color.RED
	)
	results_box.add_child(label)

func _on_challenge_complete() -> void:
	# Hook this into your game logic — unlock door, grant XP, trigger cutscene, etc.
	print("Challenge complete! Triggering game event.")

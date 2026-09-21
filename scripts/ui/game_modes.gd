extends Control

const Types = preload("res://scripts/hockey/hockey_types.gd")


func _ready() -> void:
	theme = ThemeFactory.make()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.045, 0.055)
	add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.custom_minimum_size = Vector2(540, 520)
	box.offset_left = -270
	box.offset_right = 270
	box.offset_top = -260
	box.offset_bottom = 260
	box.add_theme_constant_override("separation", 10)
	add_child(box)
	var t := Label.new()
	t.text = "Game Modes"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 28)
	box.add_child(t)
	box.add_child(_m("FIRST TO 7 vs AI", "Race to seven. Honest reaction AI.", Types.Mode.FIRST_TO_SEVEN, true, false))
	box.add_child(_m("TIMED vs AI", "Ninety seconds. Highest score wins.", Types.Mode.TIMED, true, false))
	box.add_child(_m("LOCAL", "Mouse vs WASD. Same table.", Types.Mode.FIRST_TO_SEVEN, false, true))
	box.add_child(_m("PRACTICE", "No scoreboard ending. Learn the rails.", Types.Mode.PRACTICE, false, false))
	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size.y = 44
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
	box.add_child(back)


func _m(title: String, blurb: String, mode, ai: bool, local: bool) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [title, blurb]
	b.custom_minimum_size.y = 70
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(func():
		AudioManager.play("ui")
		GameSession.reset_defaults()
		GameSession.mode = mode
		GameSession.vs_ai = ai
		GameSession.local_multi = local
		get_tree().change_scene_to_file("res://scenes/main/game.tscn")
	)
	return b

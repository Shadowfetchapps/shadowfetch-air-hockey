extends Control


func _ready() -> void:
	theme = ThemeFactory.make()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.045, 0.055)
	add_child(bg)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 70
	panel.offset_right = -70
	panel.offset_top = 40
	panel.offset_bottom = -40
	add_child(panel)
	var v := VBoxContainer.new()
	panel.add_child(v)
	var t := Label.new()
	t.text = "How to Play"
	t.add_theme_font_size_override("font_size", 28)
	v.add_child(t)
	var s := ScrollContainer.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(s)
	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text = """MALLET
The player mallet follows the mouse on the ice immediately. You stay on your half. Strike the puck; do not clip through the rails.

GOALS
A puck fully through a goal mouth scores exactly once, then the face-off resets. First to 7 wins that mode. Timed is 90 seconds. Practice never ends.

AI
The opponent tracks the puck with reaction delay and a speed cap. It uses the same table. It does not teleport through the puck.

LOCAL
Player two uses WASD on the far mallet.

Esc pauses. A puck that leaves the world is placed back at center.
"""
	s.add_child(body)
	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn"))
	v.add_child(back)

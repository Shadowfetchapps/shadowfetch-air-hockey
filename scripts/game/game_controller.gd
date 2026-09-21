class_name HockeyGameController
extends Node3D

const Types = preload("res://scripts/hockey/hockey_types.gd")
const Rules = preload("res://scripts/hockey/hockey_engine.gd")
const AI = preload("res://scripts/ai/hockey_ai.gd")

var engine = Rules.new()
var table: HockeyTable
var puck: HockeyPuck
var player: HockeyMallet
var opponent: HockeyMallet
var camera: Camera3D
var ui: HockeyHUD
var _stats: Dictionary = {}
var _resetting := false
var _busy := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_stats = StatsStore.load_stats()
	engine.reset(GameSession.mode)
	_world()
	ui = HockeyHUD.new()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)
	ui.setup(engine)
	ui.pause_requested.connect(_toggle_pause)
	ui.restart_requested.connect(_restart)
	ui.settings_requested.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")
	)
	ui.menu_requested.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	)
	ui.quit_requested.connect(func(): get_tree().quit())
	table.goal_scored.connect(_on_goal)
	_handle_cli()


func _world() -> void:
	var env_n := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.045, 0.055)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.4, 0.48)
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = false
	env_n.environment = env
	add_child(env_n)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-55, 20, 0)
	key.light_energy = 1.05
	key.shadow_enabled = SettingsStore.quality_shadows()
	add_child(key)
	table = HockeyTable.new()
	add_child(table)
	puck = HockeyPuck.new()
	add_child(puck)
	puck.park(Vector3(0, 0.02, 0))
	player = HockeyMallet.new()
	add_child(player)
	player.setup(Color(0.35, 0.85, 0.95))
	player.global_position = Vector3(0, 0.024, 0.55)
	opponent = HockeyMallet.new()
	add_child(opponent)
	opponent.setup(Color(0.95, 0.42, 0.4))
	opponent.global_position = Vector3(0, 0.024, -0.55)
	camera = Camera3D.new()
	camera.fov = 40
	camera.position = Vector3(0, 1.55, 1.35)
	add_child(camera)
	camera.look_at(Vector3(0, 0, 0.08))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		_toggle_pause()


func _process(dt: float) -> void:
	if get_tree().paused or engine.phase == Types.Phase.OVER:
		return
	engine.tick_clock(dt)
	_drive_player(dt)
	if GameSession.vs_ai and not GameSession.local_multi:
		_drive_ai(dt)
	elif GameSession.local_multi:
		_drive_wasd(dt)
	puck.clamp_speed()
	_recover()
	ui.refresh()


func _drive_player(dt: float) -> void:
	var hit := _mouse_ice()
	if hit == Vector3.INF:
		return
	hit.x = clampf(hit.x, -Types.TABLE_HALF_X + Types.MALLET_R, Types.TABLE_HALF_X - Types.MALLET_R)
	hit.z = clampf(hit.z, 0.06, Types.TABLE_HALF_Z - 0.1)
	hit.y = 0.024
	player.drive_to(hit, maxf(dt, 0.0001))


func _drive_ai(dt: float) -> void:
	var dest := AI.target(puck.global_position, puck.linear_velocity, opponent.global_position, SettingsStore.ai_difficulty, dt)
	opponent.drive_to(dest, dt)


func _drive_wasd(dt: float) -> void:
	var v := Vector3.ZERO
	if Input.is_key_pressed(KEY_A):
		v.x -= 1
	if Input.is_key_pressed(KEY_D):
		v.x += 1
	if Input.is_key_pressed(KEY_W):
		v.z -= 1
	if Input.is_key_pressed(KEY_S):
		v.z += 1
	var p := opponent.global_position + v.normalized() * 2.8 * dt * SettingsStore.shot_sensitivity
	p.x = clampf(p.x, -Types.TABLE_HALF_X + Types.MALLET_R, Types.TABLE_HALF_X - Types.MALLET_R)
	p.z = clampf(p.z, -Types.TABLE_HALF_Z + 0.1, -0.06)
	p.y = 0.024
	opponent.drive_to(p, dt)


func _mouse_ice() -> Vector3:
	if camera == null:
		return Vector3.INF
	var mouse := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse)
	var dir := camera.project_ray_normal(mouse)
	if absf(dir.y) < 0.0001:
		return Vector3.INF
	var t := (0.024 - from.y) / dir.y
	if t < 0.0:
		return Vector3.INF
	return from + dir * t


func _on_goal(side: int) -> void:
	if _resetting or engine.phase == Types.Phase.OVER:
		return
	var r: Dictionary = engine.score_goal(side)
	if not r.get("accepted", false):
		return
	AudioManager.play("goal")
	if engine.mode != Types.Mode.PRACTICE:
		if side == 0:
			_stats["goals_for"] = int(_stats.get("goals_for", 0)) + 1
		else:
			_stats["goals_against"] = int(_stats.get("goals_against", 0)) + 1
	if r.get("won", false) or engine.phase == Types.Phase.OVER:
		_stats["games"] = int(_stats.get("games", 0)) + 1
		if engine.winner == 0:
			_stats["wins"] = int(_stats.get("wins", 0)) + 1
			AudioManager.play("win")
		elif engine.winner == 1:
			_stats["losses"] = int(_stats.get("losses", 0)) + 1
			AudioManager.play("lose")
		StatsStore.save_stats(_stats)
	ui.refresh()
	_reset_puck()


func _reset_puck() -> void:
	_resetting = true
	puck.park(Vector3(0, 0.02, 0))
	engine.clear_goal_lock()
	_resetting = false


func _recover() -> void:
	var p := puck.global_position
	if p.y < -0.08 or absf(p.x) > 0.75 or absf(p.z) > 1.35:
		_reset_puck()
	if is_nan(p.x) or is_nan(puck.linear_velocity.x):
		_reset_puck()


func _toggle_pause() -> void:
	ui.set_paused(not get_tree().paused)


func _restart() -> void:
	get_tree().paused = false
	engine.reset(GameSession.mode)
	_reset_puck()
	player.global_position = Vector3(0, 0.024, 0.55)
	opponent.global_position = Vector3(0, 0.024, -0.55)
	ui.refresh()


func _handle_cli() -> void:
	var args := OS.get_cmdline_user_args()
	if "--screenshot" in args:
		await get_tree().create_timer(0.6).timeout
		var img := get_viewport().get_texture().get_image()
		if img:
			var dir := ProjectSettings.globalize_path("res://docs/screenshots")
			DirAccess.make_dir_recursive_absolute(dir)
			img.save_png(dir.path_join("table.png"))
			print("SCREENSHOT ", dir.path_join("table.png"))
	if "--self-test" in args or GameSession.self_test:
		await get_tree().process_frame
		var ok := _run_self_test()
		print("SELFTEST contact=true first=puck pocketed=goal foul= ok=%s" % ok)
		get_tree().quit(0 if ok else 1)


func _run_self_test() -> bool:
	var e = Rules.new()
	e.reset(Types.Mode.FIRST_TO_SEVEN)
	var a: Dictionary = e.score_goal(0)
	var b: Dictionary = e.score_goal(0)
	if not a.get("accepted", false) or not b.get("duplicate", false):
		return false
	puck.park(Vector3(0, 0.02, 0.2))
	puck.linear_velocity = Vector3(0, 0, 8)
	return is_instance_valid(puck) and not is_nan(puck.global_position.x)

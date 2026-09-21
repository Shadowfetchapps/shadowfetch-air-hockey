extends RefCounted

const Types = preload("res://scripts/hockey/hockey_types.gd")
const Rules = preload("res://scripts/hockey/hockey_engine.gd")
const Sim = preload("res://scripts/hockey/hockey_sim.gd")

var _failures: Array[String] = []
var _checks := 0


func run_all() -> bool:
	_rules()
	_goal_once()
	_trajectories(12000)
	_mallet_storm(4000)
	_high_speed(3000)
	print("Hockey checks: %d  failures: %d" % [_checks, _failures.size()])
	for m in _failures:
		print("FAIL: ", m)
	return _failures.is_empty()


func _rules() -> void:
	var e := Rules.new()
	e.reset(Types.Mode.FIRST_TO_SEVEN)
	for i in 6:
		e.clear_goal_lock()
		e.score_goal(0)
	_ok(e.scores[0] == 6 and e.phase != Types.Phase.OVER, "six goals still live")
	e.clear_goal_lock()
	var r: Dictionary = e.score_goal(0)
	_ok(r["won"] == true and e.winner == 0, "seventh goal wins")
	e.reset(Types.Mode.TIMED)
	e.tick_clock(Types.TIMED_SECONDS)
	_ok(e.phase == Types.Phase.OVER and e.winner == -1, "timed draw")
	e.reset(Types.Mode.TIMED)
	e.score_goal(1)
	e.tick_clock(Types.TIMED_SECONDS)
	_ok(e.winner == 1, "timed leader wins")
	e.reset(Types.Mode.PRACTICE)
	e.score_goal(0)
	e.clear_goal_lock()
	e.score_goal(0)
	_ok(e.scores[0] == 0 and e.phase != Types.Phase.OVER, "practice never ends")


func _goal_once() -> void:
	var e := Rules.new()
	e.reset(Types.Mode.FIRST_TO_SEVEN)
	var a: Dictionary = e.score_goal(0)
	var b: Dictionary = e.score_goal(0)
	_ok(a["accepted"] == true and b["duplicate"] == true, "same possession scores once")
	_ok(e.scores[0] == 1, "one point")
	e.clear_goal_lock()
	e.score_goal(0)
	_ok(e.scores[0] == 2, "new possession can score")
	_ok(e.is_in_goal(0.0, 1.05) == 0, "player goal +z")
	_ok(e.is_in_goal(0.0, -1.05) == 1, "ai goal -z")
	_ok(e.is_in_goal(0.3, 1.05) == -1, "wide of goal")


func _trajectories(n: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260920
	var goals := 0
	var walls := 0
	for i in n:
		var s := Sim.new()
		s.engine.reset(Types.Mode.PRACTICE)
		var v := Vector2(rng.randf_range(-11.0, 11.0), rng.randf_range(-11.0, 11.0))
		if v.length() < 2.0:
			v = Vector2(0, 8)
		s.reset_puck(Vector2(rng.randf_range(-0.2, 0.2), rng.randf_range(-0.2, 0.2)), v)
		for _k in 240:
			var ev: Dictionary = s.step(1.0 / 120.0)
			if str(ev.get("event", "")) == "goal":
				goals += 1
				var res: Dictionary = ev["result"]
				_ok(res.get("duplicate", false) == false, "goal accepted %d" % i)
				break
		_ok(not s.escaped, "no escape %d" % i)
		_ok(not s.nan_hit, "no nan %d" % i)
		walls += s.wall_hits
	_ok(goals > 0, "some goals in random flight")
	_ok(walls > 100, "wall contacts %d" % walls)
	_ok(n == 12000, "12000 trajectories")


func _mallet_storm(n: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	var hits := 0
	for i in n:
		var s := Sim.new()
		s.engine.reset(Types.Mode.PRACTICE)
		s.reset_puck(Vector2.ZERO, Vector2(rng.randf_range(-3, 3), rng.randf_range(-3, 3)))
		var mallet := Vector2(rng.randf_range(-0.2, 0.2), rng.randf_range(0.05, 0.35))
		var mv := Vector2(rng.randf_range(-6, 6), rng.randf_range(-8, -1))
		s.collide_mallet(mallet, mv)
		for _k in 80:
			s.step(1.0 / 180.0)
			if s.pos.distance_to(mallet) < Types.PUCK_R + Types.MALLET_R * 0.4:
				s.collide_mallet(mallet, mv)
		hits += s.mallet_hits
		_ok(not s.escaped, "mallet no escape %d" % i)
		_ok(not s.nan_hit, "mallet no nan %d" % i)
		_ok(s.pos.y <= Types.TABLE_HALF_Z + 0.05, "puck on table %d" % i)
	_ok(hits > 0, "mallet contacts")


func _high_speed(n: int) -> void:
	for i in n:
		var s := Sim.new()
		s.engine.reset(Types.Mode.FIRST_TO_SEVEN)
		s.reset_puck(Vector2(0, 0.2), Vector2(0, Types.MAX_SPEED))
		var scored := 0
		for _k in 80:
			var ev: Dictionary = s.step(1.0 / 240.0)
			if str(ev.get("event", "")) == "goal":
				scored += 1
		_ok(scored <= 1, "high speed one goal %d" % i)
		_ok(not s.escaped, "high speed contained %d" % i)
	_ok(n == 3000, "3000 high-speed shots")


func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_failures.append(msg)

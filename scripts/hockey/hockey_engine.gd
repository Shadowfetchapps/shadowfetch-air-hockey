class_name HockeyEngine
extends RefCounted

const Types = preload("res://scripts/hockey/hockey_types.gd")

var mode: Types.Mode = Types.Mode.FIRST_TO_SEVEN
var phase: Types.Phase = Types.Phase.LIVE
var scores: Array[int] = [0, 0]
var time_left: float = Types.TIMED_SECONDS
var winner: int = -1
var last_scorer: int = -1
var last_message: String = "Play."
var _goal_lock: int = -1


func reset(p_mode: Types.Mode) -> void:
	mode = p_mode
	phase = Types.Phase.LIVE
	scores = [0, 0]
	time_left = Types.TIMED_SECONDS
	winner = -1
	last_scorer = -1
	last_message = "Play."
	_goal_lock = -1


func score_goal(side: int) -> Dictionary:
	if phase == Types.Phase.OVER:
		return {"accepted": false, "duplicate": false}
	if side != 0 and side != 1:
		return {"accepted": false, "duplicate": false}
	if _goal_lock == side:
		return {"accepted": false, "duplicate": true}
	_goal_lock = side
	if mode == Types.Mode.PRACTICE:
		last_scorer = side
		last_message = "Practice goal"
		return {"accepted": true, "duplicate": false, "won": false}
	scores[side] += 1
	last_scorer = side
	last_message = "Goal"
	if mode == Types.Mode.FIRST_TO_SEVEN and scores[side] >= 7:
		winner = side
		phase = Types.Phase.OVER
		last_message = "Match"
		return {"accepted": true, "duplicate": false, "won": true}
	return {"accepted": true, "duplicate": false, "won": false}


func clear_goal_lock() -> void:
	_goal_lock = -1


func tick_clock(dt: float) -> void:
	if mode != Types.Mode.TIMED or phase == Types.Phase.OVER:
		return
	time_left = maxf(time_left - dt, 0.0)
	if time_left <= 0.0:
		phase = Types.Phase.OVER
		if scores[0] == scores[1]:
			winner = -1
			last_message = "Draw"
		else:
			winner = 0 if scores[0] > scores[1] else 1
			last_message = "Time"


func is_in_goal(x: float, z: float) -> int:
	if absf(x) > Types.GOAL_HALF_X:
		return -1
	if z > Types.TABLE_HALF_Z:
		return 0
	if z < -Types.TABLE_HALF_Z:
		return 1
	return -1

class_name HockeySim
extends RefCounted

const Types = preload("res://scripts/hockey/hockey_types.gd")
const EngineScript = preload("res://scripts/hockey/hockey_engine.gd")

var pos := Vector2.ZERO
var vel := Vector2.ZERO
var engine = EngineScript.new()
var escaped := false
var nan_hit := false
var steps := 0
var wall_hits := 0
var mallet_hits := 0


func reset_puck(p: Vector2 = Vector2.ZERO, v: Vector2 = Vector2.ZERO) -> void:
	pos = p
	vel = v
	escaped = false
	nan_hit = false
	engine.clear_goal_lock()


func step(dt: float) -> Dictionary:
	steps += 1
	pos += vel * dt
	if not is_finite(pos.x) or not is_finite(pos.y) or not is_finite(vel.x) or not is_finite(vel.y):
		nan_hit = true
		vel = Vector2.ZERO
		pos = Vector2.ZERO
		return {"event": "nan"}
	var spd := vel.length()
	if spd > Types.MAX_SPEED:
		vel = vel.normalized() * Types.MAX_SPEED
	var scored := engine.is_in_goal(pos.x, pos.y)
	if scored >= 0:
		var r: Dictionary = engine.score_goal(scored)
		pos = Vector2.ZERO
		vel = Vector2.ZERO
		return {"event": "goal", "side": scored, "result": r}
	var hit := false
	if pos.x > Types.TABLE_HALF_X - Types.PUCK_R:
		pos.x = Types.TABLE_HALF_X - Types.PUCK_R
		vel.x = -absf(vel.x)
		hit = true
	elif pos.x < -Types.TABLE_HALF_X + Types.PUCK_R:
		pos.x = -Types.TABLE_HALF_X + Types.PUCK_R
		vel.x = absf(vel.x)
		hit = true
	if pos.y > Types.TABLE_HALF_Z - Types.PUCK_R and absf(pos.x) > Types.GOAL_HALF_X:
		pos.y = Types.TABLE_HALF_Z - Types.PUCK_R
		vel.y = -absf(vel.y)
		hit = true
	elif pos.y < -Types.TABLE_HALF_Z + Types.PUCK_R and absf(pos.x) > Types.GOAL_HALF_X:
		pos.y = -Types.TABLE_HALF_Z + Types.PUCK_R
		vel.y = absf(vel.y)
		hit = true
	if hit:
		wall_hits += 1
	if absf(pos.x) > Types.TABLE_HALF_X + 0.08 or absf(pos.y) > Types.TABLE_HALF_Z + 0.12:
		escaped = true
		pos = Vector2.ZERO
		vel = Vector2.ZERO
		return {"event": "escape"}
	return {"event": "move"}


func collide_mallet(mallet: Vector2, mallet_vel: Vector2) -> void:
	var d := pos - mallet
	var min_d := Types.PUCK_R + Types.MALLET_R
	if d.length() >= min_d or d.length() < 0.0001:
		return
	var n := d.normalized()
	pos = mallet + n * min_d
	var rel := vel - mallet_vel
	var vn := rel.dot(n)
	if vn < 0.0:
		vel = vel - 1.85 * vn * n + mallet_vel * 0.35
	mallet_hits += 1
	if vel.length() > Types.MAX_SPEED:
		vel = vel.normalized() * Types.MAX_SPEED

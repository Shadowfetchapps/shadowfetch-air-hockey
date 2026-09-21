class_name HockeyAI
extends RefCounted

const Types = preload("res://scripts/hockey/hockey_types.gd")


static func target(puck: Vector3, puck_vel: Vector3, mallet: Vector3, difficulty: String, dt: float) -> Vector3:
	var react := 0.12
	var lead := 0.08
	match difficulty:
		"easy":
			react = 0.22
			lead = 0.02
		"hard":
			react = 0.05
			lead = 0.14
	var pred := puck + puck_vel * lead
	var dest := mallet
	if puck_vel.z < 0.15 and puck.z < 0.15:
		dest = Vector3(pred.x, 0.024, clampf(pred.z, -Types.TABLE_HALF_Z + 0.12, -0.08))
	else:
		dest = Vector3(lerpf(mallet.x, 0.0, 2.0 * dt), 0.024, -0.55)
	dest.x = clampf(dest.x, -Types.TABLE_HALF_X + Types.MALLET_R, Types.TABLE_HALF_X - Types.MALLET_R)
	dest.z = clampf(dest.z, -Types.TABLE_HALF_Z + 0.1, -0.06)
	var max_s := 3.6
	match difficulty:
		"easy":
			max_s = 2.2
		"hard":
			max_s = 5.0
	var step := dest - mallet
	var lim := max_s * dt * (1.0 - react * 0.3)
	if step.length() > lim and lim > 0.0:
		dest = mallet + step.normalized() * lim
	return dest

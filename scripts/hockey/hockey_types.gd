class_name HockeyTypes
extends RefCounted

enum Mode { FIRST_TO_SEVEN, TIMED, PRACTICE }
enum Phase { LIVE, FACEOFF, OVER }

const TABLE_HALF_X := 0.48
const TABLE_HALF_Z := 0.96
const GOAL_HALF_X := 0.14
const PUCK_R := 0.032
const MALLET_R := 0.055
const MAX_SPEED := 12.0
const TIMED_SECONDS := 90.0


static func mode_name(mode: Mode) -> String:
	match mode:
		Mode.TIMED:
			return "Timed"
		Mode.PRACTICE:
			return "Practice"
		_:
			return "First to 7"

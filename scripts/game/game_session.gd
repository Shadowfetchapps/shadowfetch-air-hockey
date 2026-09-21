extends Node

const Types = preload("res://scripts/hockey/hockey_types.gd")

var mode: Types.Mode = Types.Mode.FIRST_TO_SEVEN
var vs_ai: bool = true
var local_multi: bool = false
var self_test: bool = false


func reset_defaults() -> void:
	mode = Types.Mode.FIRST_TO_SEVEN
	vs_ai = true
	local_multi = false
	self_test = false


func mode_name() -> String:
	return Types.mode_name(mode)

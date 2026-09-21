class_name HockeyTable
extends Node3D

signal goal_scored(side: int)

const Types = preload("res://scripts/hockey/hockey_types.gd")


func _ready() -> void:
	_ice()
	_rails()
	_goals()


func _ice() -> void:
	var ice := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(Types.TABLE_HALF_X * 2.0 + 0.08, 0.04, Types.TABLE_HALF_Z * 2.0 + 0.08)
	ice.mesh = box
	ice.position = Vector3(0, -0.02, 0)
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.22, 0.4, 0.48)
	m.roughness = 0.18
	m.metallic = 0.35
	ice.material_override = m
	add_child(ice)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = box.size
	col.shape = sh
	body.add_child(col)
	body.position = ice.position
	add_child(body)
	var line := MeshInstance3D.new()
	var lb := BoxMesh.new()
	lb.size = Vector3(Types.TABLE_HALF_X * 2.0, 0.002, 0.01)
	line.mesh = lb
	line.position = Vector3(0, 0.001, 0)
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color(0.75, 0.88, 0.95)
	lm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line.material_override = lm
	add_child(line)


func _rails() -> void:
	_wall(Vector3(Types.TABLE_HALF_X + 0.03, 0.04, 0), Vector3(0.06, 0.1, Types.TABLE_HALF_Z * 2.0 + 0.12))
	_wall(Vector3(-Types.TABLE_HALF_X - 0.03, 0.04, 0), Vector3(0.06, 0.1, Types.TABLE_HALF_Z * 2.0 + 0.12))
	var end_w := Types.TABLE_HALF_X - Types.GOAL_HALF_X
	_wall(Vector3(Types.TABLE_HALF_X - end_w * 0.5, 0.04, Types.TABLE_HALF_Z + 0.03), Vector3(end_w, 0.1, 0.06))
	_wall(Vector3(-Types.TABLE_HALF_X + end_w * 0.5, 0.04, Types.TABLE_HALF_Z + 0.03), Vector3(end_w, 0.1, 0.06))
	_wall(Vector3(Types.TABLE_HALF_X - end_w * 0.5, 0.04, -Types.TABLE_HALF_Z - 0.03), Vector3(end_w, 0.1, 0.06))
	_wall(Vector3(-Types.TABLE_HALF_X + end_w * 0.5, 0.04, -Types.TABLE_HALF_Z - 0.03), Vector3(end_w, 0.1, 0.06))


func _wall(pos: Vector3, size: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mi.mesh = box
	mi.position = pos
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.42, 0.52, 0.58)
	m.metallic = 0.65
	m.roughness = 0.32
	mi.material_override = m
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = size
	col.shape = sh
	body.add_child(col)
	body.position = pos
	add_child(body)


func _goals() -> void:
	_goal(0, Vector3(0, 0.04, Types.TABLE_HALF_Z + 0.05))
	_goal(1, Vector3(0, 0.04, -Types.TABLE_HALF_Z - 0.05))


func _goal(side: int, pos: Vector3) -> void:
	var area := Area3D.new()
	area.collision_mask = 2
	area.monitoring = true
	area.position = pos
	var col := CollisionShape3D.new()
	var sh := BoxShape3D.new()
	sh.size = Vector3(Types.GOAL_HALF_X * 2.0, 0.1, 0.08)
	col.shape = sh
	area.add_child(col)
	area.body_entered.connect(func(body: Node):
		if body is RigidBody3D:
			goal_scored.emit(side)
	)
	add_child(area)
	var frame := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(Types.GOAL_HALF_X * 2.0 + 0.04, 0.02, 0.03)
	frame.mesh = box
	frame.position = pos + Vector3(0, 0.06, 0)
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.35, 0.85, 0.95) if side == 0 else Color(0.95, 0.45, 0.4)
	m.emission_enabled = true
	m.emission = m.albedo_color * 0.35
	frame.material_override = m
	add_child(frame)

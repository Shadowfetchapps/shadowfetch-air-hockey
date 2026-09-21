class_name HockeyMallet
extends AnimatableBody3D

const Types = preload("res://scripts/hockey/hockey_types.gd")

var radius: float = Types.MALLET_R
var last_pos := Vector3.ZERO
var velocity := Vector3.ZERO
var accent := Color(0.35, 0.85, 0.95)


func setup(color: Color) -> void:
	accent = color
	sync_to_physics = true
	collision_layer = 4
	collision_mask = 2
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = radius
	cyl.height = 0.045
	col.shape = cyl
	add_child(col)
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.72
	mesh.bottom_radius = radius
	mesh.height = 0.045
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.55
	mat.roughness = 0.3
	mi.material_override = mat
	add_child(mi)
	last_pos = global_position


func drive_to(target: Vector3, dt: float) -> void:
	var next := target
	next.y = 0.024
	velocity = (next - global_position) / maxf(dt, 0.0001)
	global_position = next
	last_pos = next


func max_speed_for(difficulty: String) -> float:
	match difficulty:
		"easy":
			return 2.4
		"hard":
			return 5.2
		_:
			return 3.6

class_name HockeyPuck
extends RigidBody3D

const Types = preload("res://scripts/hockey/hockey_types.gd")


func _ready() -> void:
	mass = 0.08
	gravity_scale = 0.0
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 8
	linear_damp = 0.18
	angular_damp = 0.8
	collision_layer = 2
	collision_mask = 1 | 2 | 4
	var col := CollisionShape3D.new()
	var cyl := CylinderShape3D.new()
	cyl.radius = Types.PUCK_R
	cyl.height = 0.012
	col.shape = cyl
	add_child(col)
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = Types.PUCK_R
	mesh.bottom_radius = Types.PUCK_R
	mesh.height = 0.012
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.09, 0.1)
	mat.metallic = 0.85
	mat.roughness = 0.22
	mi.material_override = mat
	add_child(mi)
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.86
	pm.friction = 0.04
	physics_material_override = pm
	axis_lock_linear_y = true
	axis_lock_angular_x = true
	axis_lock_angular_z = true


func park(at: Vector3) -> void:
	freeze = true
	global_position = at
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = false


func clamp_speed() -> void:
	var v := linear_velocity
	v.y = 0
	if v.length() > Types.MAX_SPEED:
		linear_velocity = v.normalized() * Types.MAX_SPEED
	else:
		linear_velocity = v

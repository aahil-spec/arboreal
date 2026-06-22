extends Node3D


@export var build_distance:float=8.0
var current_hit_position:Vector3=Vector3.ZERO
var has_hit:bool=false
var build_mode:bool=false
var ghost:Node3D=null
var selected_index:int=0

var pieces:Array=[
	{"name":"Wall","scene":preload("res://scenes/pieces/wall.tscn"),"cost":2},
	{"name":"Floor","scene":preload("res://scenes/pieces/floor.tscn"),"cost":2},
	{"name":"Roof","scene":preload("res://scenes/pieces/roof.tscn"),"cost":3},
	{"name":"Door","scene":preload("res://scenes/pieces/door.tscn"),"cost":2},
	{"name":"Campfire","scene":preload("res://scenes/pieces/campfire.tscn"),"cost":4},
	{"name":"Bed","scene":preload("res://scenes/pieces/bed.tscn"),"cost":3},
]

func _unhandled_input(event):
	if event.is_action_pressed("toggle_build"):
		build_mode=!build_mode
		if build_mode:
			_spawn_ghost()
		else:
			_remove_ghost()
	if build_mode:
		for i in range(1,7):
			if event.is_action_pressed("select_piece_%d"%i):
				selected_index=i-1
				_spawn_ghost()
		if event.is_action_pressed("place_piece") and has_hit:
			_place_piece()
@warning_ignore("unused_parameter")
func _physics_process(delta):
	var camera=get_viewport().get_camera_3d()
	if camera==null:
		return
		
	var from: Vector3=camera.global_transform.origin
	var to:Vector3=from+camera.global_transform.basis.z*-build_distance
	var space_state=get_world_3d().direct_space_state
	var query=PhysicsRayQueryParameters3D.create(from,to)
	var result=space_state.intersect_ray(query)
	
	if result:
		has_hit=true
		current_hit_position=result.position
		if build_mode and ghost:
			ghost.global_position=current_hit_position
	else:
		has_hit=false
func _spawn_ghost():
	_remove_ghost()
	var piece=pieces[selected_index]
	ghost=piece["scene"].instantiate()
	_make_transparent(ghost)
	get_tree().current_scene.add_child(ghost)
	
func _remove_ghost():
	if ghost:
		ghost.queue_free()
		ghost=null
	
func _make_transparent(node:Node):
	if node is MeshInstance3D:
		var mat =StandardMaterial3D.new()
		mat.albedo_color=Color(1,1,1,0.4)
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		node.material_override=mat
	if node is CollisionShape3D:
		node.disabled=true
	for child in node.get_children():
		_make_transparent(child)
	
func _place_piece():
	var piece=pieces[selected_index]
	if GameManager.spend_timber(piece["cost"]):
		var real_piece=piece["scene"].instantite()
		get_tree().current_scene.add_child(real_piece)
		real_piece.global_position=current_hit_position
		real_piece.piece.rotation=ghost.rotation
	else:
		print("not enough timber! need",piece["cost"])

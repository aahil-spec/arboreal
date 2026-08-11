@tool
extends Node3D

@export var terrain_node: Node3D
@export var scene_file: PackedScene
@export var object_count: int = 500
@export var scatter_size:Vector2 = Vector2(700.,700.0)
@export var generate_objects: bool = false:
	set(value):
		if value:
			_scatter_objects()
			generate_objects = false
	
func _scatter_objects():
	if not is_inside_tree() or terrain_node == null or scene_file == null:
		return
	for child in get_children():
		child.queue_free()
	var temp_tree = scene_file.instantiate()
	var mesh_list = []
	_extract_meshes(temp_tree, mesh_list)
	temp_tree.queue_free()
	if mesh_list.is_empty():
		return
	var multimesh_nodes = []
	for mesh in mesh_list:
		var mmi = MultiMeshInstance3D.new()
		mmi.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		#mmi.visibility_range_end=150.0
		#mmi.visibility_range_end_margin=10.0
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = mesh
		mm.instance_count = object_count
		mmi.multimesh = mm
		add_child(mmi)
		mmi.owner = get_tree().edited_scene_root 
		multimesh_nodes.append(mmi)
	for i in range(object_count):
		var random_x = randf_range(-scatter_size.x, scatter_size.x) + global_position.x
		var random_z = randf_range(-scatter_size.y, scatter_size.y) + global_position.z
		var global_target = Vector3(random_x, 0, random_z)
		var height = 0.0
		if terrain_node.get("data"):
			height = terrain_node.data.get_height(global_target)
		elif terrain_node.get("storage"):
			height = terrain_node.storage.get_height(global_target)
		
		if is_nan(height):
			for mmi in multimesh_nodes:
				mmi.multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(0, -5000, 0)))
			continue
			
		global_target.y = height
		var local_pos = to_local(global_target)
		
		var random_basis = Basis().rotated(Vector3.UP, randf_range(0, TAU))
		var random_scale = randf_range(0.8, 1.3) * 0.02
		random_basis = random_basis.scaled(Vector3(random_scale, random_scale, random_scale))
		var t = Transform3D(random_basis, local_pos)
		for mmi in multimesh_nodes:
			mmi.multimesh.set_instance_transform(i, t)
		
			
func _extract_meshes(node: Node, mesh_list: Array):
	if node is MeshInstance3D and node.mesh != null:
		mesh_list.append(node.mesh)
	for child in node.get_children():
		_extract_meshes(child, mesh_list)

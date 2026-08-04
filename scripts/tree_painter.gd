@tool
extends MultiMeshInstance3D

@export var tree_count:int=500
@export var scatter_radius:float=200.0
@export var generate_forest:bool=false:
	set(value):
		if value:
			_scatter_trees()
			generate_forest=false
			
func _scatter_trees():
	if multimesh==null:
		print("Please add a MultiMesh resource first!")
		return
	multimesh.instance_count=tree_count
	var space_state=get_world_3d().direct_space_state
	
	for i in range(tree_count):
		var random_x=randf_range(-scatter_radius,scatter_radius)+global_position.x
		var random_z=randf_range(-scatter_radius,scatter_radius)+global_position.z
		var from=Vector3(random_x,1000,random_z)
		var to=Vector3(random_x,-1000,random_z)
		var query=PhysicsRayQueryParameters3D.create(from,to)
		var result=space_state.intersect_ray(query)
		if result:
			var pos=result.position
			var basis=Basis().rotated(Vector3.UP,randf_range(0,TAU))
			var scale=randf_range(0.8,1.3)
			basis=basis.scaled(Vector3(scale,scale,scale))
			
			var t=Transform3D(basis,pos)
			multimesh.set_instance_transform(i,t)
		else:
			multimesh.set_instance_transform(i,Transform3D(Basis(),Vector3(0,-5000,0)))
	print("Forest planted successfully!")

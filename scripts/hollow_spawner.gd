extends Node3D


@export var hollow_scene:PackedScene=preload("res://scenes/hollow.tscn")
var spawned_hollow:Node3D=null

var has_spawned_tonight:bool=false
@warning_ignore("unused_parameter")
func _process(delta):
	var is_night=GameManager.is_night()
	if is_night:
		if not is_instance_valid(spawned_hollow) and not has_spawned_tonight:
			spawned_hollow=hollow_scene.instantiate()
			get_tree().current_scene.add_child(spawned_hollow)
			
			spawned_hollow.global_position=global_position+Vector3(0,1.0,0)
			
			has_spawned_tonight=true
	elif not is_night: 
		has_spawned_tonight=false
		if is_instance_valid(spawned_hollow):
			spawned_hollow.queue_free()

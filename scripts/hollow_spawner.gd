extends Node3D


@export var hollow_scene:PackedScene=preload("res://scenes/hollow.tscn")
var spawned_hollow:Node3D=null

var has_spawned_tonight:bool=false
@warning_ignore("unused_parameter")
func _process(delta):
	var time=GameManager.time_of_day
	var is_night=time>=18.0 or time<6.0
	
	if is_night and not is_instance_valid(spawned_hollow):
		spawned_hollow=hollow_scene.instantiate()
		
		get_tree().current_scene.add_child(spawned_hollow)
		spawned_hollow.global_position=global_position
		has_spawned_tonight=true
	elif not is_night: 
		has_spawned_tonight=false
		if is_instance_valid(spawned_hollow):
			spawned_hollow.queue_free()

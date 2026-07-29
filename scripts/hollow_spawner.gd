extends Node3D


@export var hollow_scene:PackedScene=preload("res://scenes/hollow.tscn")
@export var spawn_radius:float=40.0
@export var despawn_radius:float=60.0
@export var day_limit:int=1
@export var night_limit:int=5
@export var spawn_cooldown:float=1.3

var active_hollows:Array=[]
var cooldowm_timer:float=0.0
var player:Node3D=null
var total_spawned:int=0
var was_night:bool=false

func _ready():
	player=get_tree().current_scene.get_node_or_null("Player")
	was_night=GameManager.is_night()
@warning_ignore("unused_parameter")
func _process(delta):
	if not is_instance_valid(player):
		return
		
	for i in range(active_hollows.size()-1,-1,-1):
		if not is_instance_valid(active_hollows[i]):
			active_hollows.remove_at(i)
	var distance_to_player=global_position.distance_to(player.global_position)
	var is_night=GameManager.is_night()
	if is_night!=was_night:
		total_spawned=0
		was_night=is_night
	var current_limit=night_limit if is_night else day_limit
	
	if not is_night and active_hollows.size()>current_limit:
		var excess=active_hollows.pop_back()
		excess.queue_free()
	if cooldowm_timer>0.0:
		cooldowm_timer-=delta
	if distance_to_player<=spawn_radius:
		if active_hollows.size()<current_limit and total_spawned<current_limit and cooldowm_timer<=0.0:
			_spawn_hollow()
			cooldowm_timer=spawn_cooldown
	elif distance_to_player>despawn_radius:
		if active_hollows.size()>0:
			var out_of_range_hollow=active_hollows.pop_back()
			if is_instance_valid(out_of_range_hollow):
				out_of_range_hollow.queue_free()
				total_spawned-=1
				
func _spawn_hollow():
	var new_hollow=hollow_scene.instantiate()
	get_tree().current_scene.add_child(new_hollow)
	
	var random_x=randf_range(-2.0,2.0)
	var random_z=randf_range(-2.0,2.0)
	
	new_hollow.global_position=global_position+Vector3(random_x,1.0,random_z)
	active_hollows.append(new_hollow)
	total_spawned+=1

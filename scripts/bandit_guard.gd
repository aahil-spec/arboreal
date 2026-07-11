extends CharacterBody3D

const PATROL_SPEED:float=2.0
const CHASE_SPEED:float=4.5
const DETECT_RADIUS:float=9.0
const ALERT_DURATION:float=0.6
const MAX_HEALTH:int=40

@export var patrol_points:Array[Vector3]=[]

var current_patrol_index:int=0
var health:int=MAX_HEALTH
var player:Node3D=null
var alert_timer:float=0.0
var is_alert:bool=false
var was_detecting:bool=false

@onready var mesh:Node3D=$MeshInstance3D
@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D

func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("enemy")
	if patrol_points.is_empty():
		patrol_points=[global_position,global_position+Vector3(6,0,0)]
	nav_agent.target_position=patrol_points[0]
	
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	health-=amount
	
	var tween =create_tween()
	tween.tween_property(mesh,"scale",Vector3(1.2,1.2,1.2),0.05)
	tween.tween_property(mesh,"scale",Vector3(1.0,1.0,1.0),0.1)
	if health<=0:
		_drop_loot()
		queue_free()
		
func _drop_loot():
	var loot_options=["bandage","timber","sword_iron"]
	var drop_id=loot_options[randi()%loot_options.size()]
	GameManager.add_item(drop_id)
	print("The bandit dropped:",GameManager.items[drop_id]["name"])
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")
		
	var distance_to_player=global_position.distance_to(player.global_position)
	var detecting=distance_to_player<DETECT_RADIUS
	
	if detecting and not was_detecting:
		is_alert=true
		alert_timer=ALERT_DURATION
		print("Bandit:Hey! You there")
	was_detecting=detecting
	
	if is_alert:
		alert_timer-=delta
		var look_target=Vector3(player.global_position.x,global_position.y,player.global_position.z)
		look_at(look_target,Vector3.UP)
		velocity.x=move_toward(velocity.x,0,CHASE_SPEED)
		velocity.z=move_toward(velocity.z,0,CHASE_SPEED)
		if alert_timer<=0.0:
			is_alert=false
			
	elif detecting:
		nav_agent.target_position=player.global_position
		var next=nav_agent.get_next_path_position()
		var dir=(next-global_position).normalized()
		dir.y=0
		velocity.x=dir.x*CHASE_SPEED
		velocity.z=dir.z*CHASE_SPEED
		var look_target=Vector3(next.x,global_position.y,next.z)
		look_at(look_target,Vector3.UP)
	else:
		if nav_agent.is_navigation_finished():
			current_patrol_index=(current_patrol_index+1)
			nav_agent.target_position=patrol_points[current_patrol_index]
		var next=nav_agent.get_next_path_position()
		var dir=(next-global_position).normalized()
		dir.y=0
		velocity.x=dir.x*PATROL_SPEED
		velocity.z=dir.z*PATROL_SPEED
	move_and_slide()


func _on_hit_zone_body_entered(body: Node3D) -> void:
	pass # Replace with function body.

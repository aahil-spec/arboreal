extends CharacterBody3D


const SPEED = 4.0
const FLEE_RADIUS=6.0
const MAX_HEALTH=20
const WANDER_RADIUS=8.0

var health=MAX_HEALTH
var player:Node3D=null
var home_position:Vector3=Vector3.ZERO
var wander_target:Vector3=Vector3.ZERO

@onready var mesh:MeshInstance3D=$MeshInstance3D
@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D


func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("huntable")
	home_position=global_position
	_pick_new_wander_target()
	
func _pick_new_wander_target():
	var offset=Vector3(randf_range(-WANDER_RADIUS,WANDER_RADIUS),0,randf_range(-WANDER_RADIUS,WANDER_RADIUS))
	wander_target=home_position+offset
	
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	health-=amount
	_flash()
	print("Dear health",health)
	GameManager.add_item("raw_meat_bundle")
	queue_free()
	
func _flash():
	var flash_mat=StandardMaterial3D.new()
	flash_mat.albedo_color=Color(1,1,1)
	mesh.material_override=flash_mat
	await get_tree().create_timer(0.1).timeout
	mesh.material_override=null
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	var distance_to_player=global_position.distance_to(player.global_position)
	if distance_to_player<FLEE_RADIUS:
		var flee_direction=global_position - player.global_position
		flee_direction.y=0
		flee_direction=flee_direction.normalized()
		nav_agent.target_position=global_position+flee_direction*10.0
	else:
		if global_position.distance_to(wander_target)<1.0:
			_pick_new_wander_target()
		nav_agent.target_position=wander_target
		
	if not nav_agent.is_navigation_finished():
		var next_point=nav_agent.get_next_path_position()
		var direction=(next_point-global_position)
		direction.y=0
		direction=direction.normalized()
		velocity.x=direction.x*SPEED
		velocity.z=direction.z*SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()

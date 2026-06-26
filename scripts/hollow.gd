extends CharacterBody3D


const SPEED = 3.0
const DETECT_RADIUS:float=8.0
const MAX_HEALTH:int=90
const KNOCKBACK_FORCE:float=4.0
const KNOCKBACK_DURATION:float=0.3

var knockback_timer:float=0.0
var player:Node3D=null
var health:int=MAX_HEALTH

@onready var mesh:MeshInstance3D=$MeshInstance3D
func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("enemy")
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	health-=amount
	_flash()
	if attacker_position !=Vector3.ZERO:
		var knockback_dir=global_position-attacker_position
		knockback_dir.y=0
		knockback_dir=knockback_dir.normalized()
		velocity.x=knockback_dir.x*KNOCKBACK_FORCE
		velocity.z=knockback_dir.z*KNOCKBACK_FORCE
		knockback_timer=KNOCKBACK_DURATION
	if health<=0:
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
		
	if knockback_timer>0.0:
		knockback_timer-=delta
	else:
		
		if GameManager.is_night():
			var distance =global_position.distance_to(player.global_position)
			if distance<DETECT_RADIUS:
				var direction=(player.global_position-global_position)
				direction.y=0
				direction=direction.normalized()
				velocity.x=direction.x*SPEED
				velocity.z=direction.z*SPEED
				var look_target=Vector3(player.global_position.x,global_position.y,global_position.z)
				look_at(look_target,Vector3.UP)
			else:
				velocity.x=move_toward(velocity.x,0,SPEED)
				velocity.x=move_toward(velocity.z,0,SPEED)
		else:
			velocity.x=move_toward(velocity.x,0,SPEED)
			velocity.z=move_toward(velocity.z,0,SPEED)
	move_and_slide()
	

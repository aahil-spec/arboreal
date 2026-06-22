extends CharacterBody3D


const SPEED = 3.0
const DETECT_RADIUS:float=8.0
var player:Node3D=null

func _ready():
	player=get_tree().current_scene.get_node("Player")
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		
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
	

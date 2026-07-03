extends CharacterBody3D


const SPEED = 3.0
const DETECT_RADIUS:float=8.0
const MAX_HEALTH:int=90
const KNOCKBACK_FORCE:float=4.0
const KNOCKBACK_DURATION:float=0.3
const ALERT_DURATION:float=0.4


var knockback_timer:float=0.0
var player:Node3D=null
var health:int=MAX_HEALTH
var alert_timer:float=0.0
var is_alert:bool=false
var was_detecting:bool=false
var is_dead:bool=false

@onready var mesh=$ModelWrapper/EnemyModel
@onready var anim_player:AnimationPlayer=$ModelWrapper/EnemyModel/AnimationPlayer
@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D

func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("enemy")
	
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	if is_dead:
		return
	health-=amount
	if health<=0:
		is_dead=true
		$CollisionShape3D.set_deferred("disabled",true)
		anim_player.play("Dies")
		
		await anim_player.animation_finished
		queue_free()
	else:
		_flash()
		if attacker_position !=Vector3.ZERO:
			var knockback_dir=global_position-attacker_position
			knockback_dir.y=0
			knockback_dir=knockback_dir.normalized()
			velocity.x=knockback_dir.x*KNOCKBACK_FORCE
			velocity.z=knockback_dir.z*KNOCKBACK_FORCE
			knockback_timer=KNOCKBACK_DURATION
	
func _flash():
	var tween=create_tween()
	tween.tween_property(mesh,"scale",Vector3(1.2,1.2,1.2),0.05)
	tween.tween_property(mesh,"scale",Vector3(1.0,1.0,1.0),0.1)
func _physics_process(delta):
	if not is_on_floor():
		if is_dead:
			return
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		
	if knockback_timer>0.0:
		knockback_timer-=delta
		move_and_slide()
		return
		
	var detecting=false
	if GameManager.is_night():
		var distance =global_position.distance_to(player.global_position)
		detecting=distance<DETECT_RADIUS
		
	if detecting and not was_detecting:
		is_alert=true
		alert_timer=ALERT_DURATION
	was_detecting=detecting
	
	if is_alert:
		alert_timer-=delta
		
		var player_look=Vector3(player.global_position.x,global_position.y,player.global_position.z)
		if global_position.distance_to(player_look):
			look_at(player_look,Vector3.UP)
		velocity.x=move_toward(velocity.x,0,SPEED)
		velocity.z=move_toward(velocity.z,0,SPEED)
		if alert_timer<=0.0:
			is_alert=false
			
	elif detecting:
		nav_agent.target_position=player.global_position
		var distance_to_player=global_position.distance_to(player.global_position)
		if distance_to_player>1.5:
				var next_point=nav_agent.get_next_path_position()
				var direction=(next_point-global_position)
				direction.y=0
				if direction.length()>0.05:
					direction=direction.normalized()
					velocity.x=direction.x*SPEED
					velocity.z=direction.z*SPEED
					var look_target=global_position+direction
					look_at(look_target,Vector3.UP)
		else:
			velocity.x=move_toward(velocity.x,0,SPEED)
			velocity.z=move_toward(velocity.z,0,SPEED)
	else:
		velocity.x=move_toward(velocity.x,0,SPEED)
		velocity.z=move_toward(velocity.z,0,SPEED)
		
	var is_moving=velocity.length()>0.5
	if is_moving:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")
	move_and_slide()

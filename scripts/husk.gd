extends CharacterBody3D


const SPEED = 6.0
const DETECT_RADIUS=10.0
const MAX_HEALTH:int=80
const KNOCKBACK_FORCE:float=3.0
const KNOCKBACK_DURATION:float=0.3
const PATROL_RADIUS:float=6.0
const ALERT_DURATION:float=0.4
const ATTACK_RANGE:float=4.5


var alert_timer:float=0.0
var is_Alert:bool=false
var was_detecting:bool=false
var health:int=MAX_HEALTH
var player:Node3D=null
var knockback_timer:float=0.0
var patrol_target:Vector3=Vector3.ZERO
var home_position:Vector3=Vector3.ZERO
var is_dead:bool=false
var is_attacking:bool=false

@onready var anim_player:AnimationPlayer=$HuskModel/AnimationPlayer
@onready var husk_model:Node3D=$HuskModel
@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D
func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("enemy")
	add_to_group("boss")
	home_position=global_position
	_pick_new_patrol_target()
	anim_player.play("idle")
	
func _pick_new_patrol_target():
	var offset =Vector3(randf_range(-PATROL_RADIUS,PATROL_RADIUS),0,randf_range(-PATROL_RADIUS,PATROL_RADIUS))
	patrol_target=home_position+offset
	
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	if is_dead:
		return
	health-=amount
	_flash()
	if attacker_position!=Vector3.ZERO:
		var knockback_dir=global_position-attacker_position
		knockback_dir.y=0
		knockback_dir=knockback_dir.normalized()
		velocity.x=knockback_dir.x*KNOCKBACK_FORCE
		velocity.z=knockback_dir.z*KNOCKBACK_FORCE
		knockback_timer=KNOCKBACK_DURATION
	if health<=0:
		_die()

func _flash():
	var flash_mat=StandardMaterial3D.new()
	flash_mat.albedo_color=Color(1,1,1)
	var meshes=husk_model.find_children("*","MeshInstance3D")
	for m in meshes:
		m.material_override=flash_mat
	await get_tree().create_timer(0.1).timeout
	for m in meshes:
		m.material_override=null
func _physics_process(delta):
	if is_dead or is_attacking:
		move_and_slide()
		return
		
	var distance_to_player=global_position.distance_to(player.global_position)
	
	if distance_to_player>150.0:
		velocity.y=0
	elif not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	if knockback_timer>0.0:
		knockback_timer-=delta
		move_and_slide()
		return
		
	var detecting=distance_to_player<DETECT_RADIUS
	if detecting and distance_to_player<=ATTACK_RANGE:
		_attack()
		velocity.x=move_toward(velocity.x,0,SPEED)
		velocity.z=move_toward(velocity.z,0,SPEED)
		move_and_slide()
		return
	
	if detecting:
		var direction=(player.global_position-global_position)
		direction.y=0
		
		if direction.length()>0.05:
			direction=direction.normalized()
			velocity.x=direction.x*SPEED
			velocity.z=direction.z*SPEED
			var look_target=global_position+direction
			if global_position.distance_to(look_target)>0.01:
				look_at(look_target,Vector3.UP)
			
			if anim_player.current_animation!="run" and not is_attacking:
				anim_player.play("run")
		else:
			velocity.x=move_toward(velocity.x,0,SPEED)
			velocity.z=move_toward(velocity.z,0,SPEED)
			if anim_player.current_animation!="idle" and not is_attacking:
				anim_player.play("idle")
	else:
		if global_position.distance_to(patrol_target)<1.0:
			_pick_new_patrol_target()
		nav_agent.target_position=patrol_target
		
		var distance_to_target=global_position.distance_to(nav_agent.target_position)
		if distance_to_target>1.5:
			var next_point=nav_agent.get_next_path_position()
			var direction=(next_point-global_position)
			direction.y=0
			if direction.length()>0.05:
				direction=direction.normalized()
				velocity.x=direction.x*SPEED
				velocity.z=direction.z*SPEED
				var look_target=global_position+direction
				if global_position.distance_to(look_target)>0.01:
					look_at(look_target,Vector3.UP)
				
				if anim_player.current_animation!="run" and not is_attacking:
					anim_player.play("run")
		else:
			velocity.x=move_toward(velocity.x,0,SPEED)
			velocity.z=move_toward(velocity.z,0,SPEED)
			if anim_player.current_animation!="idle" and not is_attacking:
				anim_player.play("idle")
	move_and_slide()

func _die():
	is_dead=true
	anim_player.play("death")
	GameManager.husk_defeated=true
	GameManager.check_chronicle_unlocks()
	GameManager.spawn_drop("sword_ember",global_position)
	await anim_player.animation_finished
	queue_free()
func _attack():
	is_attacking=true
	anim_player.play("punch")
	await anim_player.animation_finished
	is_attacking=false
	

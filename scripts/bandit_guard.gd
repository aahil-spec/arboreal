extends CharacterBody3D


const SPEED = 3.5
const ATTACK_RANGE=1.8
const ATTACK_DAMAGE=15

var health=45
var player=null
var is_dead=false
var is_attacking=false

@onready var anim_player=$AuxScene/AnimationPlayer

func _ready():
	add_to_group("enemy")
	_play_anim("Idle")

func _physics_process(delta):
	if is_dead or is_attacking:
		move_and_slide()
		return
	if not is_on_floor():
		velocity.y-=9.8*delta
		
	if player!=null:
		var distance_to_player=global_position.distance_to(player.global_position)
		if distance_to_player<=ATTACK_RANGE:
			_attack()
		else:
			var direction=(player.global_position-global_position).normalized()
			direction.y=0
			if direction.length()>0.1:
				var look_target=global_position-direction
				look_at(look_target,Vector3.UP)
			velocity.x=direction.x*SPEED
			velocity.z=direction.z*SPEED
			_play_anim("Walk")
			
	else:
		velocity.x=move_toward(velocity.x,0,SPEED)
		velocity.z=move_toward(velocity.z,0,SPEED)
		_play_anim("Idle")
	move_and_slide()
	
func _attack():
	is_attacking=true
	velocity.x=0
	velocity.z=0
	_play_anim("Attack")
	await get_tree().create_timer(0.5).timeout
	
	if not is_dead and player!=null and global_position.distance_to(player.global_position) <=ATTACK_RANGE+0.5:
		GameManager.damage_player(ATTACK_DAMAGE)
	await anim_player.animation_finished
	is_attacking=false
func take_damage(amount:int,hit_pos:Vector3):
	if is_dead:
		return
	health-=amount
	var knockback_dir=(global_position-hit_pos).normalized()
	knockback_dir.y=0.4
	velocity=knockback_dir*6.0
	
	if health<=0:
		die()
		
func die():
	is_dead=true
	GameManager.update_quest_progress("defeat_bandits",1)
	GameManager.spawn_drop("bandage",global_position)
	queue_free()
	
func _play_anim(anim_name:String):
	if anim_player.current_animation==anim_name:
		return
	if anim_player.has_animation(anim_name):
		anim_player.play(anim_name)


func _on_detection_zone_body_entered(body):
	if body.name=="Player":
		player=body
	


func _on_detection_zone_body_exited(body):
	if body.name=="Player":
		player=null

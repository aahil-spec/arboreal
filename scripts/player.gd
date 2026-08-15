extends CharacterBody3D


const SPEED:float = 6.0
const JUMP_VELOCITY :float= 4.0
const MOUSE_SENSITIVITY:float=0.003
const ATTACK_DAMAGE:int=15
const FOOTSTEP_INTERVAL:float=0.4
const SPRINT_MULTIPLIER:float=1.6
const HIT_SPARK=preload("res://scenes/effects/hit_spark.tscn")
const SWIM_SPEED:float=15.0
const SWIM_UP_SPEED:float=3.0
const FLIGHT_SPEED:float=9.0
const FLIGHT_ASCEND_SPEED:float=6.0
const FLIGHT_DESCEND_SPEED:float=5.0
const FLIGHT_DRAG:float=0.88
const FLIGHT_TILT_AMOUNT:float=0.25


const ANIM_IDLE:String="Idle"
const ANIM_WALK:String="Walking"
const ANIM_RUN:String="Run"
const ANIM_JUMP:String="Jump"
const ANIM_FALL:String="Fall"
const ANIM_SWIM:String="Swimming"
const ANIM_FLY:String="Flying"
const ANIM_SWORD:String="SwordSlash"
const ANIM_PUNCH:String="Punch"
const ANIM_DEATH:String="Die"

@onready var camera_pivot:Node3D=$CameraPivot
@onready var attack_zone:Area3D=$AttackZone
var footstep_timer:float=0.0
var was_on_floor:bool=true
var survival_check_timer:float=0.0
@export var damage_vignette:ColorRect

@onready var character_model:Node3D=$CharacterModel
@onready var third_person_arm:SpringArm3D=$CameraPivot/ThirdPersonArm
@onready var third_person_cam:Camera3D=$CameraPivot/ThirdPersonArm/ThirdPersonCamera
@onready var first_person_cam:Camera3D=$CameraPivot/FirstPersonPoint/Camera3D
@onready var anim_player:AnimationPlayer=$CharacterModel/AnimationPlayer
@onready var first_person_hand:Marker3D=$CameraPivot/FirstPersonPoint/Camera3D/RightHand
@onready var grip_sword:Marker3D=$CharacterModel/AuxScene/Node/Skeleton3D/ThirdPersonhand/SwordGrip
@onready var grip_default:Marker3D=$CharacterModel/AuxScene/Node/Skeleton3D/ThirdPersonhand/DefaultGrip
@onready var wings_grip:Marker3D=$CharacterModel/AuxScene/Node/Skeleton3D/ThirdPersonhand/WingsGrip
@onready var wings_visual:Node3D=$CharacterModel/AuxScene/Node/Skeleton3D/BackAttachment3D/EmberWingsVisual
@onready var global_env:Environment
@onready var bandage_grip:Marker3D=$CharacterModel/AuxScene/Node/Skeleton3D/ThirdPersonhand/BandageGrip
var is_first_person:bool=false
var is_attacking:bool=false
var is_dead:bool=false
var current_anim:String=""
var current_held_model:Node3D=null

var flight_active:bool=false
var flight_velocity:Vector3=Vector3.ZERO

var current_water_surface_y:float=-3.0

var air_time:float=0.0
var FALL_ANIM_THRESHOLD:float=2.5
var is_jumping:bool=false

var was_in_water:bool=false
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	GameManager.player_damaged.connect(_on_player_damaged)
	
	GameManager.hotbar_changed.connect(_update_hand_visuals)
	call_deferred("_update_hand_visuals")
	third_person_cam.current=false
	first_person_cam.current=true
	
	third_person_arm.add_excluded_object(self.get_rid())
	global_env=get_viewport().find_world_3d().environment
	if global_env==null:
		global_env=get_viewport().find_world_3d().fallback_environment
func _on_player_damaged():
	_camera_shake()
	_flash_vignette()
	
func _camera_shake():
	var original_pos=camera_pivot.position
	var tween=create_tween()
	for i in range(4):
		var offset=Vector3(randf_range(-0.1,0.1),randf_range(-0.1,0.1),0)
		tween.tween_property(camera_pivot,"position",original_pos+offset,0.03)
	tween.tween_property(camera_pivot,"position",original_pos,0.05)
	
func _flash_vignette():
	if damage_vignette:
		damage_vignette.color.a=0.35
		var tween=create_tween()
		tween.tween_property(damage_vignette,"color:a",0.0,0.4)
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*0.005)
		$CameraPivot.rotate_x(-event.relative.y*0.005)
		$CameraPivot.rotation.x=clamp($CameraPivot.rotation.x,deg_to_rad(-80),deg_to_rad(80))
		
	if event.is_action_pressed("toggle_camera"):
		_toggle_camera()
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("attack") and not GameManager.build_mode and not GameManager.in_water:
		_attack()
		
	if event.is_action_pressed("wheel_up"):
		GameManager.active_hotbar_slot-=1
		if GameManager.active_hotbar_slot<0:
			GameManager.active_hotbar_slot=8
		GameManager.hotbar_changed.emit()
	elif event.is_action_pressed("wheel_down"):
		GameManager.active_hotbar_slot+=1
		if GameManager.active_hotbar_slot>8:
			GameManager.active_hotbar_slot=0
		GameManager.hotbar_changed.emit()
		
	for i in range(1,10):
		if event is InputEventKey and event.pressed and event.keycode==(KEY_0+i):
			GameManager.active_hotbar_slot=i-1
			GameManager.hotbar_changed.emit()
			break
	if event.is_action_pressed("ui_accept") and GameManager.has_wings():
		if not is_on_floor() and not GameManager.in_water and not flight_active and GameManager.flight_energy >10.0:
			_start_flight()
		elif flight_active:
			_stop_flight()
			
	if event.is_action_pressed("drop_item") and not GameManager.build_mode and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_drop_last_item()
func _attack():
	if is_attacking:
		return
	is_attacking=true
	
	var held_item=GameManager.get_acitve_hotbar_item()
	var is_holding_sword=false
	if not held_item.is_empty() and "sword" in held_item["id"].to_lower():
		is_holding_sword=true
	if is_holding_sword:
		_play_anim(ANIM_SWORD,true)
	else:
		_play_anim(ANIM_PUNCH,true)
	for body in attack_zone.get_overlapping_bodies():
		if body.is_in_group("enemy") or body.is_in_group("huntable"):
			body.take_damage(GameManager.get_attack_damage(),global_position)
			var spark=HIT_SPARK.instantiate()
			get_tree().current_scene.add_child(spark)
			spark.global_position=body.global_position+Vector3(0,1,0)
	await anim_player.animation_finished
	is_attacking=false
func _physics_process(delta):
	if is_dead:
		move_and_slide()
		return
	if is_on_floor() and not was_on_floor:
		is_jumping=false
		if flight_active:
			_stop_flight()
	was_on_floor=is_on_floor()
	if not is_on_floor() and not GameManager.in_water and not flight_active:
		air_time+=delta
	else:
		air_time=0.0
	if not GameManager.in_water and was_in_water:
		if not is_on_floor() and velocity.y>0.0:
			velocity.y=2.0
	was_in_water=GameManager.in_water
	_update_flight_energy(delta)
	survival_check_timer-=delta
	if survival_check_timer<=0.0:
		survival_check_timer=0.5
		_update_shelter_status()
		_update_heat_status()
	_update_equipment_visuals()
	var active_camera=get_viewport().get_camera_3d()
	
	if active_camera and global_env:
		var camera_y=active_camera.global_position.y
		
		if camera_y<current_water_surface_y:
			global_env.fog_enabled=true
			global_env.fog_light_color=Color(0.1,0.35,0.45)
			global_env.fog_density=lerp(global_env.fog_density,0.15,delta*5.0)
		else:
			global_env.fog_density=lerp(global_env.fog_density,0.0,delta*5.0)
			if global_env.fog_density<0.005:
				global_env.fog_enabled=false
	var input_dir :Vector2= Input.get_vector("move_left", "move_right","move_up", "move_down")
	var direction :Vector3= (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if flight_active and not GameManager.in_water:
		_handle_flight(delta,direction)
	else:
		var current_speed=SPEED+GameManager.get_speed_bonus()
		
		if GameManager.in_water:
			is_jumping=false
			var active_cam=get_viewport().get_camera_3d()
			var swim_dir=Vector3.ZERO
			if active_cam:
				swim_dir=(active_cam.global_transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized()
			if swim_dir!=Vector3.ZERO:
				velocity.x=swim_dir.x*SWIM_SPEED
				velocity.y=swim_dir.y*SWIM_SPEED
				velocity.z=swim_dir.z*SWIM_SPEED
			else:
				velocity.x=move_toward(velocity.x,0,SWIM_SPEED*0.1)
				velocity.z=move_toward(velocity.z,0,SWIM_SPEED*0.1)
				velocity.y-=9.8*delta*0.5
				velocity.y=max(velocity.y,-2.5)
			if Input.is_action_pressed("ui_accept"):
				velocity.y=SWIM_UP_SPEED
		else:
			var current_gravity=get_gravity()
			if current_gravity.length()>0.1:
				up_direction=-current_gravity.normalized()
			else:
				up_direction=Vector3.UP
			if not is_on_floor():
				velocity+=current_gravity*delta
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity+= up_direction*JUMP_VELOCITY
				is_jumping=true
			var wants_to_sprint=Input.is_action_pressed("sprint") and direction.length()>0.1 and GameManager.stamina>0.0
			GameManager.is_sprinting=wants_to_sprint
			if wants_to_sprint:
				current_speed*=SPRINT_MULTIPLIER
			
			if direction:
				velocity.x = direction.x *current_speed
				velocity.z = direction.z * current_speed
			else:
				velocity.x = move_toward(velocity.x, 0, current_speed)
				velocity.z = move_toward(velocity.z, 0, current_speed)
		var moving=direction.length()>0.1 and is_on_floor()
		if moving:
			footstep_timer-=delta
			if footstep_timer<=0.0:
				footstep_timer=FOOTSTEP_INTERVAL
		else:
			footstep_timer=0.0
			
	if global_position.y<-600.0:
		velocity=Vector3.ZERO
		if flight_active:
			_stop_flight()
		global_position=$"../PlayerSpawnPoint".global_position
	if GameManager.player_health<=0 and not is_dead:
		_die()
	_update_animation(direction.length()>0.1,GameManager.is_sprinting)
	move_and_slide()

func _update_shelter_status():
	var space_state=get_world_3d().direct_space_state
	var from=global_position+Vector3(0,0.5,0)
	var to=from+Vector3(0,50,0)
	var query=PhysicsRayQueryParameters3D.create(from,to)
	query.exclude=[get_rid()]
	var result=space_state.intersect_ray(query)
	GameManager.is_sheltered=not result.is_empty()
	
func _update_heat_status():
	var near=false
	for heat_node in get_tree().get_nodes_in_group("heat_source"):
		if global_position.distance_to(heat_node.global_position)<4.0:
			near =true
			break
	GameManager.near_heat_source=near

func _update_hand_visuals():
	if current_held_model!=null:
		current_held_model.queue_free()
		current_held_model=null
		
	var item=GameManager.get_acitve_hotbar_item()
	if item.is_empty():
		return
		
	var item_id=item["id"]
	
	if GameManager.item_models.has(item_id):
		var model_path=GameManager.item_models[item_id]
		if ResourceLoader.exists(model_path):
			var model_scene=load(model_path)
			current_held_model=model_scene.instantiate()
			
			_disable_secret_triggers(current_held_model)
			if is_first_person:
				first_person_hand.add_child(current_held_model)
				current_held_model.transform=Transform3D()
			else:
				if "sword" in item_id.to_lower():
					grip_sword.add_child(current_held_model)
				elif item_id.to_lower()=="emberwing":
					wings_grip.add_child(current_held_model)
				elif item_id.to_lower()=="bandage":
					bandage_grip.add_child(current_held_model)
				else:
					grip_default.add_child(current_held_model)
				current_held_model.transform=Transform3D()
			

		

func _start_flight():
	flight_active=true
	GameManager.is_flying=true
	flight_velocity=velocity
	
func _stop_flight():
	flight_active=false
	GameManager.is_flying=false
	velocity=flight_velocity
	
	rotation.x=0.0
	
func _update_flight_energy(delta:float):
	if flight_active:
		GameManager.flight_energy=max(
			GameManager.flight_energy-GameManager.FLIGHT_DRAIN_PER_SECOND*delta,
			0.0
		)
		if GameManager.flight_energy<=0.0:
			_stop_flight()
	elif is_on_floor():
		GameManager.flight_energy=min(
			GameManager.flight_energy+GameManager.FLIGHT_REGEN_PER_SECOND*delta,
			GameManager.MAX_FLIGHT_ENERGY
		)
		
@warning_ignore("unused_parameter")
func _handle_flight(delta:float,direction:Vector3):
	var cam_basis=camera_pivot.global_transform.basis
	var cam_forward=-cam_basis.z
	var cam_right=cam_basis.x
	
	var flat_forward=Vector3(cam_forward.x,0,cam_forward.z).normalized()
	var flat_right=Vector3(cam_right.x,0,cam_right.z).normalized()
	
	var move_input=Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		Input.get_action_strength("move_up")-Input.get_action_strength("move_down")
		
	)
	var target_velocity =Vector3.ZERO
	target_velocity+=flat_forward* move_input.y*FLIGHT_SPEED
	target_velocity+=flat_right*move_input.x*FLIGHT_SPEED
	
	var pitch_factor=-camera_pivot.rotation.x
	target_velocity.y+=pitch_factor*FLIGHT_SPEED*0.8
	
	if Input.is_action_pressed("fly_up"):
		target_velocity.y= FLIGHT_ASCEND_SPEED
	if Input.is_action_pressed("fly_down"):
		target_velocity.y= -FLIGHT_DESCEND_SPEED
	
	flight_velocity=flight_velocity.lerp(target_velocity,1.0-pow(FLIGHT_DRAG,delta*60.0))
	velocity=flight_velocity
	
	if move_input.length()>0.1:
		var titl_target=-move_input.y*FLIGHT_TILT_AMOUNT
		rotation.x=lerp(rotation.x,titl_target,delta*5.0)
	else:
		rotation.x=lerp(rotation.x,0.0,delta*5.0)

func _drop_last_item():
	if GameManager.active_hotbar_slot>=GameManager.inventory.size():
		return
	var slot_index=GameManager.active_hotbar_slot
	var item=GameManager.inventory[slot_index]
	var item_id=item["id"]
	
	item["count"]-=1
	
	if item["count"]<=0:
		GameManager.inventory.remove_at(slot_index)
	var forward=-global_transform.basis.z
	GameManager.spawn_drop(item_id,global_position+forward*1.5)
	
	GameManager.hotbar_changed.emit()
func _drop_inventory_on_death():
	var items_to_drop=GameManager.inventory.duplicate()
	GameManager.inventory.clear()
	GameManager.equipped={
		"weapon":"","armor":"","boots":"",
		"helmet":"","leggings":"","offhand":"","wings":""
	}
	for item in items_to_drop:
		var item_id=item["id"]
		var count=item.get("count",1)
		
		for i in range(count):
			var spread =Vector3(randf_range(-2.0,2.0),0.0,randf_range(-2.0,2.0))
			GameManager.spawn_drop(item_id,global_position+spread)
		
func _disable_secret_triggers(node:Node3D):
	if node is Area3D:
		node.monitoring=false
		node.monitorable=false
	if node is CollisionShape3D:
		node.disabled=true
	for child in node.get_children():
		_disable_secret_triggers(child)

func _toggle_camera():
	is_first_person=!is_first_person
	if is_first_person:
		third_person_cam.current=false
		first_person_cam.current=true
		character_model.visible=false
		third_person_arm.spring_length=0.0
		if is_instance_valid(current_held_model):
			current_held_model.reparent(first_person_hand,false)
			current_held_model.transform=Transform3D()
	else:
		third_person_cam.current=true
		first_person_cam.current=false
		character_model.visible=true
		third_person_arm.spring_length=4.0
		if is_instance_valid(current_held_model):
			var item=GameManager.get_acitve_hotbar_item()
			if not item.is_empty():
				var item_id=item["id"].to_lower()
				if "sword" in item_id:
					current_held_model.reparent(grip_sword,false)
				elif item_id=="emberwing":
					current_held_model.reparent(wings_grip,false)
				elif item_id=="bandage":
					current_held_model.reparent(bandage_grip,false)
				else:
					current_held_model.reparent(grip_default,false)
					current_held_model.transform=Transform3D()
		
		
	
func _play_anim(anim_name:String,force:bool=false):
	if current_anim==anim_name and not force:
		return
	if not anim_player.has_animation(anim_name):
		return
	current_anim=anim_name
	anim_player.play(anim_name)
	
func _update_animation(is_moving:bool,is_sprinting:bool):
	if is_dead:
		_play_anim(ANIM_DEATH)
		return
	if is_attacking:
		return
	if GameManager.in_water:
		_play_anim(ANIM_SWIM)
		return
	if flight_active:
		_play_anim(ANIM_FLY)
		return
	if not is_on_floor():
		if velocity.y>0.5 and is_jumping:
			_play_anim(ANIM_JUMP)
			return
		elif air_time>FALL_ANIM_THRESHOLD:
			_play_anim(ANIM_FALL)
			return
	if is_moving and is_sprinting:
		_play_anim(ANIM_RUN)
	elif is_moving:
		_play_anim(ANIM_WALK)
	else:
		_play_anim(ANIM_IDLE)
func _die():
	is_dead=true
	_drop_inventory_on_death()
	_play_anim(ANIM_DEATH,true)
	await get_tree().create_timer(2.0).timeout
	_respawn()
func _respawn():
	is_dead=false
	GameManager.heal_player(GameManager.MAX_PLAYER_HEALTH)
	if flight_active:
		_stop_flight()
	global_position=$"../PlayerSpawnPoint".global_position
	GameManager.player_invincible=true
	await get_tree().create_timer(2.0).timeout
	GameManager.player_invincible=false
func _update_equipment_visuals():
	if wings_visual:
		if GameManager.equipped.has("wings") and GameManager.equipped["wings"] !="":
			wings_visual.visible=true
		else:
			wings_visual.visible=false
	

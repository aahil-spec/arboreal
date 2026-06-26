extends CharacterBody3D


const SPEED:float = 5.0
const JUMP_VELOCITY :float= 4.5
const MOUSE_SENSITIVITY:float=0.003
const ATTACK_DAMAGE:int=15
const FOOTSTEP_INTERVAL:float=0.4

@onready var camera_pivot:Node3D=$CameraPivot
@onready var attack_zone:Area3D=$AttackZone
var footstep_timer:float=0.0
var was_on_floor:bool=true
@export var damage_vignette:ColorRect
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	GameManager.player_damaged.connect(_on_player_damaged)
	
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
		rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
		camera_pivot.rotation.x=clamp(camera_pivot.rotation.x,-1.2,1.2)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			
	if event.is_action_pressed("attack") and not GameManager.build_mode:
		_attack()
func _attack():
	var mesh=$MeshInstance3D
	var original_pos=mesh.position
	var lunge_tween=create_tween()
	lunge_tween.tween_property(mesh,"position",original_pos+Vector3(0,0,-0.3),0.05)
	lunge_tween.tween_property(mesh,"position",original_pos,0.1)
	for body in attack_zone.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(ATTACK_DAMAGE,global_position)
			
func _physics_process(delta):
	if is_on_floor() and not was_on_floor:
		_squash()
	was_on_floor=is_on_floor()
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity")* delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir :Vector2= Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction :Vector3= (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	var moving=direction.length()>0.1 and is_on_floor()
	if moving:
		footstep_timer-=delta
		if footstep_timer<=0.0:
			footstep_timer=FOOTSTEP_INTERVAL
	else:
		footstep_timer=0.0
	if global_position.y<-50.0:
		velocity=Vector3.ZERO
		global_position=$"../PlayerSpawnPoint".global_position
	if GameManager.player_health<=0:
		GameManager.heal_player(GameManager.MAX_PLAYER_HEALTH)
		global_position=$"../PlayerSpawnPoint".global_position
		GameManager.player_invincible=true
		await get_tree().create_timer(2.0).timeout
		GameManager.player_invincible=false
	move_and_slide()
func _squash():
	var mesh=$MeshInstance3D
	var original_scale=mesh.scale
	var tween=create_tween()
	tween.tween_property(mesh, "scale", Vector3(original_scale.x * 1.2, original_scale.y * 0.7, original_scale.z * 1.2), 0.06)
	tween.tween_property(mesh,"scale",original_scale,0.12)

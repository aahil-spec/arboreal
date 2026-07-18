extends CharacterBody3D


const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const MOUSE_SENSITIVITY:float=0.003
const GRAVITY_STRENGTH:float=20.0

var gravity_dir:Vector3=Vector3.DOWN

var target_basis:Basis=Basis.IDENTITY

@onready var camera_pivot:Node3D=$CameraPivot

var pitch:float=0.0

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	target_basis=global_transform.basis
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		var yaw_angle=-event.relative.x*MOUSE_SENSITIVITY
		target_basis=target_basis*Basis(Vector3.UP,yaw_angle)
		
		pitch-=event.relative.y*MOUSE_SENSITIVITY
		pitch=clamp(pitch,-1.2,1.2)
		camera_pivot.rotation.x=pitch
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			
	if event.is_action_pressed("ui_down"):
		_set_gravity(Vector3.DOWN)
	if event.is_action_pressed("ui_up"):
		_set_gravity(Vector3.UP)
	if event.is_action_pressed("ui_left"):
		_set_gravity(Vector3.LEFT)
	if event.is_action_pressed("ui_right"):
		_set_gravity(Vector3.RIGHT)
		
func _set_gravity(new_dir:Vector3):
	if gravity_dir==new_dir: return
	gravity_dir=new_dir
	velocity=Vector3.ZERO
	
	var new_up=-gravity_dir
	var current_forward=-target_basis.z
	
	var new_forward=current_forward-new_up*current_forward.dot(new_up)
	
	if new_forward.length()<0.1:
		new_forward=target_basis.y-new_up*target_basis.y.dot(new_up)
		
	var new_z=-new_forward.normalized()
	var new_x=new_up.cross(new_z).normalized()
	new_z=new_x.cross(new_up).normalized()
	
	target_basis=Basis(new_x,new_up,new_z)
	
	var flash=get_tree().current_scene.get_node_or_null("CanvasLayer/GravityFlash")
	if flash:
		flash.color=Color(0.5,0.1,1.0,0.4)
		flash.visible=true
		var tween=create_tween()
		tween.tween_property(flash,"color:a",0.0,0.25)
		tween.tween_callback(func():flash.visible=false)
		
func _physics_process(delta):
	var fall_speed=velocity.dot(gravity_dir)
	velocity -=gravity_dir*fall_speed
	
	fall_speed+=GRAVITY_STRENGTH*delta
	velocity+=gravity_dir*fall_speed
	
	global_transform.basis=global_transform.basis.slerp(target_basis,12.0*delta)
	
	global_transform.basis=global_transform.basis.orthonormalized()
	
	var label=get_tree().current_scene.get_node_or_null("CanvasLayer/GravityLabel")
	if label:
		var dir_name="↓ Down"
		if gravity_dir==Vector3.UP:dir_name="↑ Up"
		elif gravity_dir==Vector3.LEFT:dir_name="← Left"
		elif gravity_dir==Vector3.RIGHT:dir_name="→ Right"
		label.text="Gravity:"+dir_name
		
	var local_forward=-global_transform.basis.z
	var local_right=global_transform.basis.x
	var move_input=Vector2.ZERO
	
	move_input.x=Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	move_input.y=Input.get_action_strength("move_down")-Input.get_action_strength("move_up")
	
	var move_dir=(local_forward*-move_input.y+local_right*move_input.x).normalized()
	
	var vertical_velocity=gravity_dir*fall_speed
	var horizontol_velocity=velocity-vertical_velocity
	
	if move_dir.length()>0.1:
		horizontol_velocity=horizontol_velocity.lerp(move_dir*SPEED,0.2)
	else:
		horizontol_velocity=horizontol_velocity.lerp(Vector3.ZERO,0.15)
		
	velocity=horizontol_velocity+vertical_velocity
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity+=-gravity_dir*JUMP_VELOCITY
	move_and_slide()

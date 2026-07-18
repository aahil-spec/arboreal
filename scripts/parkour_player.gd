extends CharacterBody3D


const SPEED = 6.0
const JUMP_VELOCITY = 5.0
const MOUSE_SENSITIVITY:float=0.003
const GRAVITY_STRENGTH:float=20.0
const ROTATION_SPEED:float=12.0

var gravity_dir:Vector3=Vector3.DOWN
var target_rotation:Quaternion=Quaternion.IDENTITY
var current_rotation:Quaternion=Quaternion.IDENTITY

@onready var camera_pivot:Node3D=$CameraPivot
var yaw:float=0.0
var pitch:float=0.0

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		yaw-=event.relative.x*MOUSE_SENSITIVITY
		pitch-=event.relative.y*MOUSE_SENSITIVITY
		pitch=clamp(pitch,-1.2,1.2)
		
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
	gravity_dir=new_dir
	velocity=Vector3.ZERO
	
	var new_up=-gravity_dir
	var new_forward=Vector3(sin(yaw),0,cos(yaw))
	
	if abs(new_up.dot(new_forward))>0.99:
		new_forward=Vector3(0,0,1) if abs(new_up.y)>0.9 else Vector3(0,1,0)
	var new_right=new_up.cross(new_forward).normalized()
	new_forward=new_right.cross(new_up).normalized()
	@warning_ignore("shadowed_variable_base_class")
	var basis=Basis(new_right,new_up,-new_forward)
	target_rotation=basis.get_rotation_quaternion()
	
	var flash=get_tree().current_scene.get_node_or_null("CanvasLayer/GravityFlash")
	if flash:
		flash.color=Color(0.5,0.1,1.0,0.4)
		flash.visible=true
		var tween=create_tween()
		tween.tween_property(flash,"color:a",0.0,0.25)
		tween.tween_callback(func():flash.visible=false)
		
func _physics_process(delta):
	velocity +=gravity_dir*GRAVITY_STRENGTH*delta
	
	current_rotation=current_rotation.slerp(target_rotation,ROTATION_SPEED*delta)
	global_transform.basis=Basis(current_rotation)
	
	camera_pivot.rotation.y=yaw
	camera_pivot.rotation.x=pitch
	
	
	var label=get_tree().current_scene.get_node_or_null("CanvasLayer/GravityLabel")
	if label:
		var dir_name="↓ Down"
		if gravity_dir==Vector3.UP:dir_name="↑ Up"
		elif gravity_dir==Vector3.LEFT:dir_name="← Left"
		elif gravity_dir==Vector3.RIGHT:dir_name="→ Right"
		label.text="Gravity:"+dir_name
	var local_forward=-global_transform.basis.z
	var local_right=global_transform.basis.x
	@warning_ignore("unused_variable")
	var local_up=global_transform.basis.y
	
	var move_input=Vector2.ZERO
	if Input.is_action_pressed("ui_up") and gravity_dir==Vector3.DOWN:
		pass
	move_input.x=Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	move_input.y=Input.get_action_strength("move_up")-Input.get_action_strength("move_down")
	
	var move_dir=(local_forward*-move_input.y+local_right*move_input.x).normalized()
	
	if move_dir.length()>0.1:
		velocity.x=lerp(velocity.x,move_dir.x*SPEED,0.2)
		velocity.z=lerp(velocity.z,move_dir.z*SPEED,0.2)
	else:
		velocity.x=lerp(velocity.x,0.0,0.15)
		velocity.z=lerp(velocity.z,0.0,0.15)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity+=-gravity_dir*JUMP_VELOCITY
	move_and_slide()

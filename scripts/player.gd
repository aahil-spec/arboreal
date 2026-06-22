extends CharacterBody3D


const SPEED:float = 5.0
const JUMP_VELOCITY :float= 4.5
const MOUSE_SENSITIVITY:float=0.003
@onready var camera_pivot:Node3D=$CameraPivot

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
		camera_pivot.rotation.x=clamp(camera_pivot.rotation.x,-1.2,1.2)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
func _physics_process(delta):
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

	move_and_slide()

extends CharacterBody3D


const SPEED = 4.0
const FLEE_RADIUS=6.0
const MAX_HEALTH=20
const WANDER_RADIUS=8.0

var health=MAX_HEALTH
var player:Node3D=null
var home_position:Vector3=Vector3.ZERO
var wander_target:Vector3=Vector3.ZERO

@onready var mesh:MeshInstance3D=$MeshInstance3D
@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D


func _ready():
	player=get_tree().current_scene.get_node("Player")
	add_to_group("huntable")
	home_position=global_position
	_pick_new_wander_target()
	
func _pick_new_wander_target():
	var offset=Vector3(randf_range(-WANDER_RADIUS,WANDER_RADIUS),0,randf_range(-WANDER_RADIUS,WANDER_RADIUS))
	wander_target=home_position+offset
	
func take_damage(amount:int,attacker_position:Vector3=Vector3.ZERO):
	health-=amount
	_flash()
	print("Dear health",health)
	GameManager.add_item("raw_meat_bundle")
	queue_free()
	
func _flash():
	var flash_mat=StandardMaterial3D.new()
	flash_mat.albedo_color=Color(1,1,1)
	mesh.material_override=flash_mat
	await get_tree().create_timer(0.1).timeout
	mesh.material_override=null
	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

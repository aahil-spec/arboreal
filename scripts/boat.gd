extends RigidBody3D

const BOAT_SPEED:float=40.0
const BOAT_TURN_SPEED:float=3.0
const BUOYANCY_FORCE:float=18.0
const WAVE_BOB_AMOUNT:float=0.15
const WAVE_BOB_SPEED:float=1.5
const DRAG:float=0.92

var player_aboard:bool=false
var player_ref:Node3D=null
var boarding_player_in_range:bool=false

@onready var boarding_point:Marker3D=$BoardingPoint
@onready var board_zone:Area3D=$BoardZone

func _ready():
	board_zone.body_entered.connect(_on_board_zone_entered)
	board_zone.body_exited.connect(_on_board_zone_exited)
	gravity_scale=0.0
	
	axis_lock_angular_x=true
	axis_lock_angular_z=true
func _on_board_zone_entered(body):
	if body.name=="Player":
		boarding_player_in_range=true
		player_ref=body
		
func _on_board_zone_exited(body):
	if body.name=="Player":
		boarding_player_in_range=false
		
func _unhandled_input(event):
	if event.is_action_pressed("interact"):
		if boarding_player_in_range and not player_aboard:
			_board_player()
		elif player_aboard:
			_disembark_player()
			
func _board_player():
	player_aboard=true
	player_ref.get_node("CollisionShape3D").disabled=true
	
	player_ref.get_parent().remove_child(player_ref)
	add_child(player_ref)
	player_ref.global_position=boarding_point.global_position
	player_ref.set_physics_process(false)
	print("Boarded the boat.Press E to disembark")
	
func _disembark_player():
	player_aboard=false
	var world_pos=player_ref.global_position +Vector3(3,0.5,0)
	remove_child(player_ref)
	get_tree().current_scene.add_child(player_ref)
	player_ref.global_position=world_pos
	player_ref.set_physics_process(true)
	player_ref.get_node("CollisionShape3D").disabled=false
	print("Disembarked")
	
func _physics_process(delta):
	var water_y=GameManager.water_y_level
	var boat_y=global_position.y
	var float_offset=1.7
	
	var depth_below_surface=(water_y+float_offset)-boat_y
	
	var bouyancy=depth_below_surface*BUOYANCY_FORCE
	apply_central_force(Vector3(0,bouyancy,0))
	
	linear_velocity*=DRAG
	
	var bob=sin(Time.get_ticks_msec()*0.001*WAVE_BOB_SPEED) *WAVE_BOB_AMOUNT
	apply_central_force(Vector3(0,bob,0))
	if player_aboard:
		var forward=-global_transform.basis.z
		var turn=0.0
		if Input.is_action_pressed("ui_left"):
			turn=BOAT_TURN_SPEED
		if Input.is_action_pressed("ui_right"):
			turn=-BOAT_TURN_SPEED
		rotate_y(turn*delta)
		
		if Input.is_action_pressed("ui_up"):
			apply_central_force(forward*BOAT_SPEED)
		if Input.is_action_pressed("ui_down"):
			apply_central_force(-forward*BOAT_SPEED*0.5)
	if player_aboard and player_ref:
		player_ref.global_position=boarding_point.global_position

extends CharacterBody3D

@export var dialogue_lines:Array=["Nice weather today.","Stay safe out there","The shrine has been dark too long"]
@export var wander_point_a:Vector3=Vector3.ZERO
@export var wander_point_b:Vector3=Vector3(5,0,5)

var player_in_range:bool=false
var current_line:int=0
var going_to_b:bool=true

@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D

func _ready():
	wander_point_a=global_position
	_pick_target()
	
func _pick_target():
	nav_agent.target_position=wander_point_b if going_to_b else wander_point_a
	
func _on_talk_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true
		
func _on_talk_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		current_line=0
		get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel").visible=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		var label=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel")
		label.visible=true
		label.text=dialogue_lines[current_line]
		current_line=(current_line+1)%dialogue_lines.size()
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		
	if GameManager.is_night():
		velocity.x=move_toward(velocity.x,0,3.0)
		velocity.x=move_toward(velocity.z,0,3.0)
		move_and_slide()
		return
		
	if nav_agent.is_navigation_finished():
		going_to_b=!going_to_b
		_pick_target()
	else:
		var next=nav_agent.get_next_path_position()
		var dir=(next-global_position).normalized()
		dir.y=0
		velocity.x=dir.x*1.5
		velocity.z=dir.z*1.5
		
	move_and_slide()

func _offer_quests():
	if "clear_bandits" not in GameManager.active_quests and "clear_bandits" not in GameManager.completed_quests:
		GameManager.start_quest("clear_bandits")
		print("Village Elder:Please,deal with those bandits.")

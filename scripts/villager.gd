extends CharacterBody3D

@export var dialogue_lines:Array=["Nice weather today.","Stay safe out there","The shrine has been dark too long"]
@export var wander_radius:float=15.0


var player_in_range:bool=false
var current_line:int=0
var home_position:Vector3
var navigation_ready:bool=false

@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D
@onready var anim_player:AnimationPlayer=$Model/AnimationPlayer
func _ready():
	home_position=global_position
	anim_player.play("Idle")
	
	await get_tree().create_timer(0.2).timeout
	navigation_ready=true
	_pick_target()
	
func _pick_target():
	if not navigation_ready:
		return
	var safe_target=global_position
	
	for i in range(10):
		var random_x=randf_range(-wander_radius,wander_radius)
		var random_z=randf_range(-wander_radius,wander_radius)
		var random_target=home_position+Vector3(random_x,0,random_z)
		var map=get_world_3d().navigation_map
		var candidate=NavigationServer3D.map_get_closest_point(map,random_target)
		if candidate.distance_to(global_position)>3.0:
			safe_target=candidate
			break
	nav_agent.target_position=safe_target
	
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
		_offer_quests()
		current_line=(current_line+1)%dialogue_lines.size()
		
func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		
	if GameManager.is_night():
		velocity.x=move_toward(velocity.x,0,3.0)
		velocity.z=move_toward(velocity.z,0,3.0)
		move_and_slide()
		anim_player.play("Idle")
		return
	if not navigation_ready:
		move_and_slide()
		return
		
	if nav_agent.is_navigation_finished():
		anim_player.play("Idle")
		_pick_target()
	else:
		var next=nav_agent.get_next_path_position()
		var dir=(next-global_position).normalized()
		dir.y=0
		velocity.x=dir.x*1.5
		velocity.z=dir.z*1.5
		anim_player.play("Walking")
		
		if dir.length()>0.1:
			var look_target=global_position+dir
			$Model.look_at(look_target,Vector3.UP)
	move_and_slide()

func _offer_quests():
	if "clear_bandits" not in GameManager.active_quests and "clear_bandits" not in GameManager.completed_quests:
		GameManager.start_quest("clear_bandits")
		print("Village Elder:Please,deal with those bandits.")

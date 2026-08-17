extends CharacterBody3D

@export var dialogue_lines:Array=["Nice weather today.", "Stay safe out there.", "The shrine has been dark too long."]
@export var wander_radius:float=15.0

var player_in_range:bool=false
var current_line:int=0
var home_position:Vector3
var navigation_ready:bool=false
var is_waiting:bool=false

@onready var nav_agent:NavigationAgent3D=$NavigationAgent3D
@onready var anim_player:AnimationPlayer=$Model/AnimationPlayer

func _ready():
	home_position=global_position
	anim_player.play("Idle")
	
	await get_tree().create_timer(1.5).timeout
	navigation_ready=true
	_pick_target()
	
func _pick_target():
	if not navigation_ready:
		return
	var best_target=global_position
	var max_distance=0.0
	var map=get_world_3d().navigation_map
	
	for i in range(15):
		var random_x=randf_range(-wander_radius,wander_radius)
		var random_z=randf_range(-wander_radius,wander_radius)
		var random_target=home_position+Vector3(random_x,0,random_z)
		
		var closet=NavigationServer3D.map_get_closest_point(map,random_target)
		var flat_pos=Vector2(global_position.x,global_position.z)
		var flat_candidate=Vector2(closet.x,closet.z)
		var dist=flat_pos.distance_to(flat_candidate)
		
		if dist>max_distance:
			max_distance=dist
			best_target=closet
		if dist>4.0:
			break
	nav_agent.target_position=best_target
	
func _on_talk_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true
func _on_talk_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		current_line=0
		var dialogue_ui=get_tree().current_scene.get_node_or_null("DialogueUI")
		if dialogue_ui:
			dialogue_ui.hide_message()
	
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		var dialogue_ui=get_tree().current_scene.get_node_or_null("DialogueUI")
		if dialogue_ui:
			dialogue_ui.show_message(dialogue_lines[current_line])
			current_line+=1
			if current_line>=dialogue_lines.size():
				current_line=0
				_offer_quest()
			
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -=ProjectSettings.get_setting("physics/3d/default_gravity")*delta
		
	if GameManager.is_night():
		velocity.x=move_toward(velocity.x,0,3.0)
		velocity.z=move_toward(velocity.z,0,3.0)
		move_and_slide()
		anim_player.play("Idle")
		return
	if not navigation_ready:
		move_and_slide()
		return
	if is_waiting:
		velocity.x=move_toward(velocity.x,0,5.0)
		velocity.z=move_toward(velocity.z,0,5.0)
		move_and_slide()
		return
	var flat_pos=Vector2(global_position.x,global_position.z)
	var flat_target=Vector2(nav_agent.target_position.x,nav_agent.target_position.z)
	var distance_to_target=flat_pos.distance_to(flat_target)
	
	if distance_to_target<3.0:
		_take_a_break()
	else:
		var next=nav_agent.get_next_path_position()
		var dir=next-global_position
		dir.y=0
		
		if dir.length()>0.05:
			dir=dir.normalized()
			velocity.x=dir.x*5.0
			velocity.z=dir.z*5.0
			anim_player.play("Walking")
			var look_target=$Model.global_position+dir
			$Model.look_at(look_target,Vector3.UP,true)
		else:
			@warning_ignore("standalone_expression")
			_take_a_break
	move_and_slide()
	
func _take_a_break():
	is_waiting=true
	
	velocity.x=move_toward(velocity.x,0,5.0)
	velocity.z=move_toward(velocity.z,0,5.0)
	anim_player.play("Idle")
	
	await get_tree().create_timer(2.0).timeout
	
	_pick_target()
	is_waiting=false
	
func _offer_quest():
	if "clear_bandits" not in GameManager.active_quests and "clear_bandits" not in GameManager.completed_quests:
		GameManager.start_quest("clear_bandits")

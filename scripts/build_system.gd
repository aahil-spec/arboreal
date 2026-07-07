extends Node3D


@export var timber_label:Label
@export var selected_label:Label
@export var ember_label:Label
@export var build_distance:float=8.0

@onready var health_label:Label=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/HealthLabel")
@onready var nav_region:NavigationRegion3D=get_tree().current_scene.get_node("NavigationRegion3D")
@onready var equipped_label:Label=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/EquippedLabel")
@onready var hunger_bar:ProgressBar=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer2/HungerBar")
@onready var thirst_bar:ProgressBar=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer2/ThirstBar")
@onready var stamina_bar:ProgressBar=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer2/StaminaBar")
@onready var warmth_bar:ProgressBar=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer2/WarmthBar")
@onready var breath_bar:ProgressBar=get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/BreathBar")
var current_hit_position:Vector3=Vector3.ZERO
var has_hit:bool=false
var build_mode:bool=false
var ghost:Node3D=null
var selected_index:int=0

var pieces:Array=[
	{"name":"Wall","scene":preload("res://scenes/pieces/wall.tscn"),"cost":2,"height_offset": 1.0},
	{"name":"Floor","scene":preload("res://scenes/pieces/floor.tscn"),"cost":2,"height_offset": 0.1},
	{"name":"Roof","scene":preload("res://scenes/pieces/roof.tscn"),"cost":3,"height_offset": 0.1},
	{"name":"Door","scene":preload("res://scenes/pieces/door.tscn"),"cost":2,"height_offset": 1.0},
	{"name":"Campfire","scene":preload("res://scenes/pieces/campfire.tscn"),"cost":4,"height_offset": 0.2},
	{"name":"Bed","scene":preload("res://scenes/pieces/bed.tscn"),"cost":3,"height_offset": 0.25},
	{"name":"Stairs","scene":preload("res://scenes/pieces/stairs.tscn"),"cost":3,"height_offset":0.25},
	{"name":"Window","scene":preload("res://scenes/pieces/window.tscn"),"cost":3,"height_offset":1.0},
	{"name":"Fence","scene":preload("res://scenes/pieces/fence.tscn"),"cost":2,"height_offset":0.5},
	{"name": "Torch", "scene": preload("res://scenes/pieces/torch.tscn"), "cost":2,"height_offset": 0.3},
]

func _unhandled_input(event):
	if event.is_action_pressed("save_game"):
		SaveSystem.save_game()
	if event.is_action_pressed("load_game"):
		SaveSystem.load_game()
	if event.is_action_pressed("toggle_build") and not GameManager.in_water:
		build_mode=!build_mode
		GameManager.build_mode=build_mode
		if build_mode:
			_spawn_ghost()
		else:
			_remove_ghost()
	if build_mode:
		
		if event.is_action_pressed("rotate_left") and ghost:
			ghost.rotation.y-=PI/2
		if event.is_action_pressed("rotate_right") and ghost:
			ghost.rotation.y+=PI/2
		for i in range(1,7):
			if event.is_action_pressed("select_piece_%d"%i):
				selected_index=i-1
				_spawn_ghost()
		if event is InputEventMouseButton and event.pressed:
			if event.button_index==MOUSE_BUTTON_WHEEL_UP:
				selected_index=(selected_index+1)%pieces.size()
				_spawn_ghost()
			elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:
				selected_index=(selected_index-1+pieces.size())%pieces.size()
				_spawn_ghost() 
		if event.is_action_pressed("place_piece"):
			if has_hit:
				_place_piece()
				


@warning_ignore("unused_parameter")
func _process(delta):
	timber_label.text="Timber:"+str(GameManager.timber)
	selected_label.text = "Selected: " + pieces[selected_index]["name"] + " (cost " + str(pieces[selected_index]["cost"]) + ")"
	ember_label.text="Embers:"+str(GameManager.embers_collected)+"/3"
	health_label.text="Health:"+str(GameManager.player_health)+"/"+str(GameManager.MAX_PLAYER_HEALTH)
	hunger_bar.value=GameManager.hunger
	thirst_bar.value=GameManager.thirst
	stamina_bar.value=GameManager.stamina
	warmth_bar.value=GameManager.warmth
	breath_bar.value=GameManager.breath
	breath_bar.visible=GameManager.in_water
	get_tree().current_scene.get_node("CanvasLayer/UnderwaterOverlay").visible=GameManager.in_water
	var weapon_name="None"
	if GameManager.equipped["weapon"]!="":
		weapon_name=GameManager.items[GameManager.equipped["weapon"]]["name"]
	equipped_label.text="Weapon:"+weapon_name
	
@warning_ignore("unused_parameter")
func _physics_process(delta):
	var camera=get_viewport().get_camera_3d()
	if camera==null:
		return
		
	var from: Vector3=camera.global_transform.origin
	var to:Vector3=from+camera.global_transform.basis.z*-build_distance
	var space_state=get_world_3d().direct_space_state
	var query=PhysicsRayQueryParameters3D.create(from,to)
	query.exclude=[get_parent().get_rid()]
	var result=space_state.intersect_ray(query)
	
	if result:
		has_hit=true
		var hit =result.position
		var grid_size:float=1.0
		hit.x=round(hit.x/grid_size)*grid_size
		hit.z=round(hit.z/grid_size)*grid_size
		current_hit_position=hit
		if build_mode and ghost:
			var offset=pieces[selected_index]["height_offset"]
			ghost.global_position=current_hit_position+Vector3(0,offset,0)
	else:
		has_hit=false
func _spawn_ghost():
	_remove_ghost()
	var piece=pieces[selected_index]
	ghost=piece["scene"].instantiate()
	_make_transparent(ghost)
	get_tree().current_scene.add_child(ghost)
	
func _remove_ghost():
	if ghost:
		ghost.queue_free()
		ghost=null
	
func _make_transparent(node:Node):
	if node is MeshInstance3D:
		var mat =StandardMaterial3D.new()
		mat.albedo_color=Color(1,1,1,0.4)
		mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
		node.material_override=mat
	if node is CollisionShape3D:
		node.disabled=true
	for child in node.get_children():
		_make_transparent(child)
	
func _place_piece():
	var piece=pieces[selected_index]
	if GameManager.spend_timber(piece["cost"]):
		var real_piece=piece["scene"].instantiate()
		real_piece.add_to_group("placed_piece")
		get_tree().current_scene.add_child(real_piece)
		var pos=current_hit_position +Vector3(0,piece["height_offset"],0)
		real_piece.global_position=pos
		real_piece.rotation=ghost.rotation
		GameManager.record_pieces(piece["name"],pos,real_piece.rotation)
		real_piece.add_to_group("navmesh_source")
		nav_region.bake_navigation_mesh()
		if piece["name"]=="Campfire" or piece["name"]=="Torch":
			real_piece.add_to_group("heat_source")
		
	else:
		print("not enough timber! need",piece["cost"])

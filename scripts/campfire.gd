extends Node3D


@onready var anim_player=$Campfire_anim2/AnimationPlayer
@onready var light=$OmniLight3D
@onready var fbx_root=$Campfire_anim2

const NIGHT_START=18.0
const DAY_START=6.0

var is_lit=true

func _ready():
	add_to_group("heat_source")
	_check_time()
	
func _process(_delta):
	_check_time()
	
func _check_time():
	var current_time=GameManager.time_of_day
	var should_be_night=current_time>=NIGHT_START or current_time<DAY_START
	
	if should_be_night and not is_lit:
		_ignite()
	elif not should_be_night and is_lit:
		_extinguish()
		
func _ignite():
	is_lit=true
	light.visible=true
	anim_player.play("Take 001")
	
	for child in fbx_root.get_children():
		if "fire_part" in child.name:
			child.visible=true
			
func _extinguish():
	is_lit=false
	light.visible=false
	anim_player.stop()
	
	for child in fbx_root.get_children():
		if "fire_part" in child.name:
			child.visible=false

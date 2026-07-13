extends Panel

@onready var minimap_texture:TextureRect=$MinimapTexture
@onready var compass_label:Label=$CompassLabel
@onready var player_dot:ColorRect=$PlayerDot

var viewport:SubViewport=null
var location_dots:Array=[]

var location_data:Array=[
	{"name":"Village","world_pos":Vector3(-250,4,-173),"color":Color(0.9,0.85,0.6)},
	{"name":"Dock","world_pos":Vector3(80,0,-60),"color":Color(0.5,0.7,1.0)},
	{"name":"Bandits","world_pos":Vector3(-330,5,-2711),"color":Color(1,0.3,0.3)},
	{"name":"Shrine","world_pos":Vector3(40,0,30),"color":Color(1,0.7,0.2)},
	{"name":"Hollow","world_pos":Vector3(386,4,176),"color":Color(0.6,0.3,0.7)},
]

@export var minimap_world_size:float=120.0

func _ready():
	await get_tree().process_frame
	var player=get_tree().current_scene.get_node_or_null("Player")
	if player:
		viewport=player.get_node_or_null("MinimapViewport")
		if viewport:
			minimap_texture.texture=viewport.get_texture()
	_build_location_dots()
	
func _build_location_dots():
	for loc in location_data:
		if not loc["name"] in GameManager.discovered_locations:
			continue
		var dot=ColorRect.new()
		dot.size=Vector2(6,6)
		dot.color=loc["color"]
		dot.set_meta("world_pos",loc["world_pos"])
		add_child(dot)
		location_dots.append(dot)
		
@warning_ignore("unused_parameter")
func _process(delta):
	if not viewport:
		return
	var player=get_tree().current_scene.get_node_or_null("Player")
	if not player:
		return
	_update_location_dots(player)
	_update_compass(player)
	_check_new_discoveries()
	
func _update_location_dots(player:Node3D):
	var panel_center=Vector2(size.x*0.5,size.y*0.5)
	var player_world_pos=player.global_position
	for dot in location_dots:
		var world_pos=dot.get_meta("world_pos")
		var world_offset=Vector3(world_pos.x-player_world_pos.x,0,world_pos.z-player_world_pos.z)
		var map_offset=Vector2(world_offset.x,world_offset.z)/minimap_world_size*size.x
		var screen_pos=panel_center+map_offset-Vector2(3,3)
		dot.position=screen_pos
		dot.visible=(screen_pos.x>0 and screen_pos.x<size.x and screen_pos.y>0 and screen_pos.y<size.y)
		
func _update_compass(player:Node3D):
	var angle=rad_to_deg(player.rotation.y)
	angle=fmod(angle+360.0,360.0)
	var directions=["N","NW","W","SW","S","SE","E","NE","N"]
	var index=int((angle+22.5)/45.0)%8
	compass_label.text=directions[index]
	
func _check_new_discoveries():
	for loc in location_data:
		if loc["name"] in GameManager.discovered_locations:
			var already_added=false
			for dot in location_dots:
				if dot.get_meta("world_pos")==loc["world_pos"]:
					already_added=true
					break
			if not already_added:
				var dot=ColorRect.new()
				dot.size=Vector2(6,6)
				dot.color=loc["color"]
				dot.set_meta("world_pos",loc["world_pos"])
				add_child(dot)
				location_dots.append(dot)
		

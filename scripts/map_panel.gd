extends Panel


@export var world_size:Vector2=Vector2(6143,6143)
@export var world_center:Vector2=Vector2(-1023.5,1023.5)

@onready var marker_layer:Control=$MarkerLayer
@onready var map_image:TextureRect=$MapImage

var location_data:Array=[]
var player_dot:ColorRect=null

func _ready():
	location_data=[
		{"name":"Embermoor Village","world_pos":Vector3(-325.34,-3.43,-250.745),"color":Color(0.9,0.85,0.6)},
		{"name":"Fisherman's Dock","world_pos":Vector3(-195.21,3.63,-472.95),"color":Color(0.5,0.7,1.0)},
		{"name":"Bandit Camp","world_pos":Vector3(-921.63,4.5,-2711.43),"color":Color(1,0.3,0.3)},
		{"name":"The Shrine","world_pos":Vector3(40,0,30),"color":Color(1,0.7,0.2)},
		{"name":"Ashen Hollow","world_pos":Vector3(386.66,8.07,176.122),"color":Color(0.6,0.3,0.7)},
		
	]
	_build_markers()
	
func _build_markers():
	for loc in location_data:
		if loc["name"] in GameManager.discovered_locations:
			var dot=ColorRect.new()
			dot.size=Vector2(10,10)
			dot.color=loc["color"]
			dot.position= _world_to_map(loc["world_pos"])-Vector2(5,5)
			marker_layer.add_child(dot)
			
			var label=Label.new()
			label.text=loc["name"]
			label.add_theme_font_size_override("font_size",9)
			label.position=_world_to_map(loc["world_pos"])+Vector2(8,-6)
			marker_layer.add_child(label)
		else:
			var unknown=Label.new()
			unknown.text="???"
			unknown.position=_world_to_map(loc["world_pos"])
			marker_layer.add_child(unknown)
	
func _world_to_map(world_pos:Vector3)->Vector2:
	var map_size=map_image.size
	var normalized=Vector2(
		(world_pos.x-world_center.x)/world_size.x+0.5,
		(world_pos.z-world_center.y)/world_size.y+0.5,
	)
	return normalized*map_size
	
@warning_ignore("unused_parameter")
func _process(delta):
	if visible and player_dot:
		var player=get_tree().current_scene.get_node_or_null("Player")
		if player:
			player_dot.position=_world_to_map(player.global_position)-Vector2(4,4)

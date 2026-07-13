extends Camera3D


var player:Node3D=null


func _ready():
	await get_tree().process_frame
	player=get_tree().current_scene.get_node_or_null("Player")
	
@warning_ignore("unused_parameter")
func _process(delta):
	if player:
		global_position=player.global_position+Vector3(0,80,0)
		global_rotation = Vector3(deg_to_rad(-90), player.global_rotation.y, 0)

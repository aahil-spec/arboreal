extends Node

const SAVE_PATH="user://arboreal_save.json"

var piece_scenes:Dictionary={
	"Wall":"res://scenes/pieces/wall.tscn",
	"Floor":"res://scenes/pieces/floor.tscn",
	"Roof":"res://scenes/pieces/roof.tscn",
	"Door":"res://scenes/pieces/door.tscn",
	"Campfire":"res://scenes/pieces/campfire.tscn",
	"Bed":"res://scenes/pieces/bed.tscn",
}

func save_game():
	var player=get_tree().current_scene.get_node("Player")
	var data ={
		"timber":GameManager.timber,
		"embers_collected":GameManager.embers_collected,
		"collected_ember_names":GameManager.collected_ember_names,
		"placed_pieces":GameManager.placed_pieces,
		"player_position":{"x":player.global_position.x,"y":player.global_position.y,"z":player.global_position.z}
	}
	var file=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Game saved")
	
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("no save file found")
		return
	var file =FileAccess.open(SAVE_PATH,FileAccess.READ)
	var data=JSON.parse_string(file.get_as_text())
	file.close()
	
	GameManager.timber=data["timber"]
	GameManager.embers_collected=data["embers_collected"]
	GameManager.collected_ember_names=data["collected_ember_names"]
	GameManager.placed_pieces=data["placed_pieces"]
	
	for node in get_tree().get_nodes_in_group("placed_piece"):
		node.queue_free()
		
	for entry in GameManager.placed_pieces:
		var scene_path=piece_scenes[entry["name"]]
		var piece=load(scene_path).instantiate()
		piece.add_to_group("placed_piece")
		get_tree().current_scene.add_child(piece)
		var pos =entry["position"]
		piece.global_position=Vector3(pos["x"],pos["y"],pos["z"])
		var rot=entry["rotation"]
		piece.rotation=Vector3(rot["x"],rot["y"],rot["z"])
		
	for ember_node in get_tree().get_nodes_in_group("ember"):
		if ember_node.name in GameManager.collected_ember_names:
			ember_node.queue_free()
			
	var player =get_tree().current_scene.get_node("Player")
	var ppos=data["player_position"]
	player.global_position=Vector3(ppos["x"],ppos["y"],ppos["z"])
	
	print("game loaded")

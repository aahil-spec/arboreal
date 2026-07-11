extends Node

const SAVE_PATH="user://arboreal_save.json"

var piece_scenes:Dictionary={
	"Wall":"res://scenes/pieces/wall.tscn",
	"Floor":"res://scenes/pieces/floor.tscn",
	"Roof":"res://scenes/pieces/roof.tscn",
	"Door":"res://scenes/pieces/door.tscn",
	"Campfire":"res://scenes/pieces/campfire.tscn",
	"Bed":"res://scenes/pieces/bed.tscn",
	"Stairs":"res://scenes/pieces/stairs.tscn",
	"Window":"res://scenes/pieces/window.tscn",
	"Fence":"res://scenes/pieces/fence.tscn",
	"Torch":"res://scenes/pieces/torch.tscn",
	
}

func save_game():
	var player=get_tree().current_scene.get_node("Player")
	var data ={
		"timber":GameManager.timber,
		"collected_timber_names":GameManager.collected_timber_names,
		"fiber":GameManager.fiber,
		"collected_fiber_names": GameManager.collected_fiber_names,
		"embers_collected":GameManager.embers_collected,
		"collected_ember_names":GameManager.collected_ember_names,
		"placed_pieces":GameManager.placed_pieces,
		"player_health":GameManager.player_health,
		"shrine_lit":GameManager.shrine_lit,
		"husk_defeated":GameManager.husk_defeated,
		"inventory":GameManager.inventory,
		"equipped":GameManager.equipped,
		"collected_item_pickup_names":GameManager.collected_item_pickup_names,
		"player_position":{"x":player.global_position.x,"y":player.global_position.y,"z":player.global_position.z},
		"hunger":GameManager.hunger,
		"thirst":GameManager.thirst,
		"stamina":GameManager.stamina,
		"warmth":GameManager.warmth,
		"collected_berry_names":GameManager.collected_berry_names,
		"breath":GameManager.breath,
		"discovered_locations":GameManager.discovered_locations,
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
	GameManager.collected_timber_names=data["collected_timber_names"]
	GameManager.embers_collected=data["embers_collected"]
	GameManager.collected_ember_names=data["collected_ember_names"]
	GameManager.placed_pieces=data["placed_pieces"]
	GameManager.player_health=data["player_health"]
	GameManager.shrine_lit=data["shrine_lit"]
	GameManager.husk_defeated=data["husk_defeated"]
	GameManager.inventory=data["inventory"]
	var loaded_equipped=data["equipped"]
	for slot in GameManager.equipped.keys():
		if loaded_equipped.has(slot):
			GameManager.equipped[slot]=loaded_equipped[slot]
	GameManager.collected_item_pickup_names=data["collected_item_pickup_names"]
	GameManager.hunger=data["hunger"]
	GameManager.thirst=data["thirst"]
	GameManager.stamina=data["stamina"]
	GameManager.warmth=data["warmth"]
	GameManager.collected_berry_names=data["collected_berry_names"]
	GameManager.fiber=data["fiber"]
	GameManager.collected_fiber_names=data["collected_fiber_names"]
	GameManager.breath=data["breath"]
	GameManager.discovered_locations=data.get("discovered_locations",[])
	for node in get_tree().get_nodes_in_group("placed_piece"):
		node.queue_free()
		
	for entry in GameManager.placed_pieces:
		var scene_path=piece_scenes[entry["name"]]
		var piece=load(scene_path).instantiate()
		piece.add_to_group("placed_piece")
		piece.add_to_group("navmesh_source")
		if entry["name"]=="Campfire" or entry["name"]=="Torch":
			piece.add_to_group("heat_source")
		get_tree().current_scene.add_child(piece)
		var pos =entry["position"]
		piece.global_position=Vector3(pos["x"],pos["y"],pos["z"])
		var rot=entry["rotation"]
		piece.rotation=Vector3(rot["x"],rot["y"],rot["z"])
		
	var nav_region=get_tree().current_scene.get_node("NavigationRegion3D")
	nav_region.bake_navigation_mesh()
	for ember_node in get_tree().get_nodes_in_group("ember"):
		if ember_node.name in GameManager.collected_ember_names:
			ember_node.queue_free()
	for timber_node in get_tree().get_nodes_in_group("timber"):
		if timber_node.name in GameManager.collected_timber_names:
			timber_node.queue_free()
	for item_node in get_tree().get_nodes_in_group("item_pickup"):
		if item_node.name in GameManager.collected_item_pickup_names:
			item_node.queue_free()
	if GameManager.husk_defeated:
		for boss_node in get_tree().get_nodes_in_group("boss"):
			boss_node.queue_free()
	for berry_node in get_tree().get_nodes_in_group("berry"):
		if berry_node.name in GameManager.collected_berry_names:
			berry_node.queue_free()
	for fiber_node in get_tree().get_nodes_in_group("fiber"):
		if fiber_node.name in GameManager.collected_fiber_names:
			fiber_node.queue_free()
	var player =get_tree().current_scene.get_node("Player")
	var ppos=data["player_position"]
	player.global_position=Vector3(ppos["x"],ppos["y"],ppos["z"])
	
	print("game loaded")

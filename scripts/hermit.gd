extends CharacterBody3D


var player_in_range:bool=false
var current_line:int=0
var lines:Array=[]

func _get_lines():
	if GameManager.husk_defeated:
		return[
			"you did it.arboreal owes you a debt it cant repay.",
			"rest now,traveler. youve earned it",
		]
	elif GameManager.shrine_lit:
		return[
			"the shrines light reached further than i'd hoped",
			"something stirred north in the ashen hollow",
			"go and see whats woken be careful"
		]
	elif GameManager.embers_collected>0:
		return[
			"youre making progress."+str (GameManager.embers_collected)+"of 3 embers found",
			"the ruins hold the rest keep looking"
		]
	else:
		return[
			"..the shrines gone dark traveler",
			"find the three embers hidden in the old ruins",
			"bring them back and we might just see another sunrise"
		]
func _on_interact_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true

func _on_interact_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		current_line=0
		get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel").visible=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		lines=_get_lines()
		var label = get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel")
		label.visible=true
		label.text=lines[current_line]
		current_line+=1
		if current_line>=lines.size():
			current_line=0
			_offer_quests()
			
func _offer_quests():
	for quest_id in ["find_embers","defeat_husk"]:
		if quest_id not in GameManager.active_quests and quest_id not in GameManager.completed_quests:
			GameManager.start_quest(quest_id)
			print("Hermit gives you a new quest:",GameManager.quest_definitions[quest_id]["title"])
			break

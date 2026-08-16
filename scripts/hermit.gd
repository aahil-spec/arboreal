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
		var dialogue_ui=get_tree().current_scene.get_node_or_null("DialogueUI")
		if dialogue_ui:
			dialogue_ui.hide_message()
		
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		lines=_get_lines()
		var dialogue_ui=get_tree().current_scene.get_node_or_null("DialogueUI")
		if dialogue_ui:
			dialogue_ui.show_message(lines[current_line])
		current_line+=1
		if current_line>=lines.size():
			current_line=0
			_offer_quests()
			
func _offer_quests(): 
	for quest_id in ["find_embers","defeat_husk"]:
		if quest_id not in GameManager.active_quests and quest_id not in GameManager.completed_quests:
			GameManager.start_quest(quest_id)
			var quest_title=GameManager.quest_definitions[quest_id]["title"]
			if quest_id=="find_embers":
				GameManager.add_item("bandage","1")
				print("Hermit gives you a new quest:",quest_title)
				_trigger_tutorial_reminder()
				break
func _trigger_tutorial_reminder():
	await get_tree().create_timer(15.0).timeout
	var has_timber=GameManager.has_item("timber")
	var has_fiber=GameManager.has_item("fiber")
	
	if not has_timber or not has_fiber:
		GameManager.quest_alert.emit("Tip: Gather Timber & Fiber")

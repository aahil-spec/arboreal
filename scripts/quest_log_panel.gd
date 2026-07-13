extends Panel


@onready var quest_list:VBoxContainer=$QuestScroll/QuestList

func _ready():
	visible=false
	
func refresh():
	for child in quest_list.get_children():
		child.queue_free()
		
	if GameManager.active_quests.is_empty() and GameManager.completed_quests.is_empty():
		var empty_label=Label.new()
		empty_label.text="No active quests."
		quest_list.add_child(empty_label)
		return
	for quest_id in GameManager.active_quests:
		_add_quest_entry(quest_id,false)
		
	if not GameManager.completed_quests.is_empty():
		var divider=Label.new()
		divider.text="_Completed_"
		divider.modulate=Color(0.6,0.6,0.6)
		quest_list.add_child(divider)
		for quest_id in GameManager.completed_quests:
			_add_quest_entry(quest_id,true)
			
func _add_quest_entry(quest_id:String,completed:bool):
	var quest=GameManager.quest_definitions[quest_id]
	var progress=GameManager.quest_progress.get(quest_id,{})
	
	var title_label=Label.new()
	title_label.text=("✓ "if completed else "• ")+quest["title"]
	title_label.modulate=Color(0.5,0.9,0.5) if completed else Color(1,0.85,0.3)
	title_label.add_theme_font_size_override("font_size",22)
	quest_list.add_child(title_label)
	
	if not completed:
		var desc_label=Label.new()
		desc_label.text=quest["description"]
		desc_label.modulate=Color(0.75,0.75,0.75)
		desc_label.add_theme_font_size_override("font_size",16)
		desc_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		quest_list.add_child(desc_label)
		
		for objective in quest["objectives"]:
			var obj_label=Label.new()
			var current=progress.get(objective["type"],0)
			var target=objective["target"]
			if objective["type"]=="discover_location":
				var done=objective["target"] in GameManager.discovered_locations
				obj_label.text=("  ✓ " if done else "  ○ ") + objective["text"]
				obj_label.modulate=Color(0.5,0.9,0.5) if done else Color(0.8,0.8,0.8)
			else:
				var done=current>=target
				obj_label.text=("  ✓ " if done else "  ○ ") + objective["text"] + " (" + str(min(current, target)) + "/" + str(target) + ")"
				obj_label.modulate=Color(0.5,0.9,0.5) if done else Color(0.8,0.8,0.8)
			obj_label.add_theme_font_size_override("font_size",16)
			quest_list.add_child(obj_label)
			
		var spacer=Control.new()
		spacer.custom_minimum_size=Vector2(0,8)
		quest_list.add_child(spacer)

extends CanvasLayer


@onready var popup_box=$PopupBox
@onready var quest_name_label=$PopupBox/MarginContainer/VBoxContainer/QuestNameLabel

@onready var title_label=$PopupBox/MarginContainer/VBoxContainer/TitleLabel
@onready var prompt_label=$PopupBox/MarginContainer/VBoxContainer/PromptLabel
var current_tween:Tween=null

func _ready():
	popup_box.hide()
	GameManager.quest_alert.connect(show_quest)
func show_quest(quest_name:String):
	popup_box.modulate.a=0.0
	popup_box.show()
	quest_name_label.text=quest_name
	
	if quest_name.begins_with("Tip:"):
		title_label.text="SURVIVAL HINT"
		prompt_label.hide()
	elif quest_name.begins_with("Lore:"):
		title_label.text="CHRONICLE UPDATED"
		prompt_label.hide()
		quest_name_label.text=quest_name.trim_prefix("Lore:")
	else:
		title_label.text="NEW QUEST DISCOVERED"
		prompt_label.show()
	if current_tween:
		current_tween.kill()
		
	current_tween=create_tween()
	current_tween.tween_property(popup_box,"modulate:a",1.0,0.5)
	current_tween.tween_interval(3.5)
	current_tween.tween_property(popup_box,"modulate:a",0.0,1.0)
	current_tween.tween_callback(popup_box.hide)

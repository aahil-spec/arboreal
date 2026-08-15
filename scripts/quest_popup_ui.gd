extends CanvasLayer


@onready var popup_box=$PopupBox
@onready var quest_name_label=$PopupBox/MarginContainer/VBoxContainer/QuestNameLabel

var current_tween:Tween=null

func _ready():
	popup_box.hide()
	GameManager.quest_alert.connect(show_quest)
func show_quest(quest_name:String):
	popup_box.modulate.a=0.0
	popup_box.show()
	quest_name_label.text=quest_name
	
	if current_tween:
		current_tween.kill()
		
	current_tween=create_tween()
	current_tween.tween_property(popup_box,"modulate:a",1.0,0.5)
	current_tween.tween_interval(3.5)
	current_tween.tween_property(popup_box,"modulate:a",0.0,1.0)
	current_tween.tween_callback(popup_box.hide)

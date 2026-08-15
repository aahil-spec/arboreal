extends CanvasLayer


@onready var dialogue_box=$DialogueBox
@onready var dialogue_text=$DialogueBox/MarginContainer/DialogueText

var current_tween:Tween=null
func _ready():
	dialogue_box.visible=false
	
	dialogue_text.scroll_active=false
	
func show_message(text_to_show:String):
	dialogue_box.visible=true
	dialogue_text.text=text_to_show
	
	dialogue_text.visible_ratio=0.0
	
	if current_tween:
		current_tween.kill()
		
	current_tween=create_tween()
	current_tween.tween_property(dialogue_text,"visible_ratio",1.0,2.0)
func hide_message():
	dialogue_box.visible=false

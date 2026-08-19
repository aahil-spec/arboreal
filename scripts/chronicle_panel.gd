extends Panel


@onready var page_title:Label=$PageTitle
@onready var page_text:RichTextLabel=$PageText
@onready var page_indidcator:Label=$HBoxContainer/PageIndicator

var current_page_index:int=0

func _ready():
	visible=false

func open_book():
	visible=true
	current_page_index=GameManager.chronicle_last_page
	_clamp_to_unlocked()
	_refresh_page()
	_animate_open()
	
func _animate_open():
	modulate.a=0.0
	scale=Vector2(0.95,0.95)
	var tween=create_tween().set_parallel(true)
	tween.tween_property(self,"modulate:a",1.0,0.2)
	tween.tween_property(self,"scale",Vector2(1.0,1.0),0.2)
	
func close_book():
	GameManager.chronicle_last_page=current_page_index
	var tween=create_tween().set_parallel(true)
	tween.tween_property(self,"modulate:a",0.0,0.12)
	tween.tween_property(self,"scale",Vector2(0.95,0.95),0.12)
	tween.chain().tween_callback(func():visible=false)
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _clamp_to_unlocked():
	if current_page_index>=GameManager.chronicle_pages.size():
		current_page_index=0
		
func _refresh_page():
	var pages=GameManager.chronicle_pages
	var page=pages[current_page_index]
	var unlocked=GameManager.is_page_unlocked(page)
	
	if unlocked:
		page_title.text=page["title"]
		page_text.text=page["text"]
		page_title.modulate=Color(0.9,0.8,0.5)
	else:
		page_title.text="???(Locked)"
		page_text.text="[i]This page is bound shut. Something about your journey hasn't happened yet.[/i]"
		page_title.modulate=Color(0.5,0.45,0.4)
		
	page_indidcator.text="Page"+str(current_page_index+1)+"of"+str(pages.size())
	$HBoxContainer/PrevButton.disabled=current_page_index<=0
	$HBoxContainer/NextButton.disabled=current_page_index>=pages.size()-1
	
func _on_prev

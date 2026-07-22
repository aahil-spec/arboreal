extends Control


@onready var name_input:LineEdit=$CenterContainer/VBoxContainer/NameInput
@onready var error_label:Label=$CenterContainer/VBoxContainer/ErrorLabel
@onready var confirm_btn:Button=$CenterContainer/VBoxContainer/HBoxContainer/ConfirmButton

func _ready():
	error_label.visible=false
	name_input.grab_focus()
	name_input.text_submitted.connect(_on_name_submitted)
	
func _on_confirm_button_pressed():
	_start_with_name()
	
func _on_name_submitted(text:String):
	_start_with_name()
	
func _start_with_name():
	var name_text=name_input.text.strip_edges()
	if name_text.length()<2:
		error_label.text="Name must be at least 2 characters."
		error_label.visible=true
		return
		
	if name_text.length()>20:
		error_label.text="Name must be 20 characters or fewer."
		error_label.visible=true
		return
	GameManager.player_name=name_text
	get_tree().change_scene_to_file("res://scenes/main.scn")
	
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

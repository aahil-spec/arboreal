extends Control

@onready var v_box=$MarginContainer/VBoxContainer

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	
	for button in v_box.get_children():
		if button is Button:
			button.pivot_offset=button.size/2
			button.mouse_entered.connect(_on_button_hover.bind(button))
			button.mouse_exited.connect(_on_button_exit.bind(button))
			button.pressed.connect(_on_button_pressed.bind(button.name))
			
func _on_button_hover(button:Button):
	var tween=create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(button,"scale",Vector2(1.1,1.1),0.2)
	tween.tween_property(button,"position:x",15.0,0.2)
	
func _on_button_exit(button:Button):
	var tween=create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(button,"scale",Vector2(1.0,1.0),0.2)
	tween.tween_property(button,"position:x",0.0,0.2)
	
func _on_button_pressed(button_name:String):
	if button_name=="PlayButton":
		get_tree().change_scene_to_file("res://scenes/main.scn")
	elif button_name =="QuitButton":
		get_tree().quit()

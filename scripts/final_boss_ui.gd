extends ColorRect


func _ready():
	hide()
	
func show_choice():
	show()
	get_tree().paused=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	
func _on_yes_button_pressed():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://locations/scenes/arena.scn")
	
func _on_no_button_pressed():
	hide()
	get_tree().paused=false
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

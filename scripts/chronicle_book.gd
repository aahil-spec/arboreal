extends StaticBody3D

var player_in_range:bool=false

func _on_read_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true


func _on_read_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		var chronicle_ui=get_tree().current_scene.get_node_or_null("CanvasLayer/ChroniclePanel")
		chronicle_ui.open_book()
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

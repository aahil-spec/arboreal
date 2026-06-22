extends CharacterBody3D


var player_in_range:bool=false
var current_line:int=0
var lines:Array=[
	"...the shrine's gone dark,traveler.",
	"Find the three embers hidden in the old ruins.",
	"Bring them back, and we might just see another sunrise."
]
func _on_interact_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true

func _on_interact_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		current_line=0
		get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel").visible=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		var label = get_tree().current_scene.get_node("CanvasLayer/VBoxContainer/DialogueLabel")
		label.visible=true
		label.text=lines[current_line]
		current_line+=1
		if current_line>=lines.size():
			current_line=0

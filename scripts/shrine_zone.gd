extends Area3D


@onready var shrine_light:OmniLight3D=get_parent().get_node("OmniLight3D")

func _on_body_entered(body):
	if body.name == "Player" and not GameManager.shrine_lit:
		if GameManager.embers_collected >= 3:
			GameManager.shrine_lit = true
			GameManager.update_quest_progress("light_shrine")
			shrine_light.light_energy = 16.0
			
			var tween=create_tween()
			tween.tween_property(shrine_light,"light_energy",3.0,2.0)
			GameManager.quest_alert.emit("Tip: Return to the Hermit")

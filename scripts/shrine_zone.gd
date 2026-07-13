extends Area3D


@onready var shrine_light:OmniLight3D=get_parent().get_node("OmniLight3D")

func _on_body_entered(body):
	if body.name == "Player" and not GameManager.shrine_lit:
		if GameManager.embers_collected >= 3:
			GameManager.shrine_lit = true
			GameManager.update_quest_progress("defeat_husk")
			shrine_light.light_energy = 3.0
			shrine_light.light_color = Color(1, 0.6, 0.2)

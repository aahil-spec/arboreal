extends Area3D


@onready var shrine_light:OmniLight3D=get_parent().get_node("OmniLight3D")
var lit:bool=false

func _on_body_entered(body):
	if body.name == "Player" and not lit:
		if GameManager.embers_collected >= 3:
			lit = true
			shrine_light.light_energy = 3.0
			shrine_light.light_color = Color(1, 0.6, 0.2)

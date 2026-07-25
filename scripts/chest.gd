extends StaticBody3D


var opened:bool=false
@onready var anim_player:AnimationPlayer=$Sketchfab_Scene/AnimationPlayer

func _on_chest_zone_body_entered(body):
	if body.name=="Player" and not opened:
		opened =true
		GameManager.add_item("emberwing")
		print("You Found the Emberwing!")
		if anim_player:
			anim_player.play("Armature|ArmatureAction")

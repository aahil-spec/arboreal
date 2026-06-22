extends Area3D

func _on_body_entered(body):
	if body.name=="Player" and GameManager.embers_collected>0:
		GameManager.embers_collected-=1
		

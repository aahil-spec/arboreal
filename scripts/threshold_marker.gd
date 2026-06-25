extends Area3D

var triggered:bool=false

func _on_body_entered(body):
	if body.name=="Player" and not triggered:
		triggered=true
		if GameManager.shrine_lit:
			print("The air here is different..something has been waititng")
		else:
			print("This place feels wrong to enter yet")

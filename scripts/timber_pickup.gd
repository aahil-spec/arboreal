extends Area3D


@export var amount:int=5



func _on_body_entered(body):
	if body.name=="Player":
		GameManager.add_timber(amount)
		queue_free()
	

extends Area3D


@export var amount:int=3

func _on_body_entered(body):
	if body.name=="Player":
		GameManager.add_fiber(amount,name)
		queue_free()

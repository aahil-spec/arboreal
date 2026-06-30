extends Area3D

@export var hunger_amount:float=25.0

func _on_body_entered(body):
	if body.name=="Player":
		GameManager.eat(hunger_amount,name)
		queue_free()

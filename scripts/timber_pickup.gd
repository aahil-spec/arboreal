extends Area3D


@export var amount:int=5



func _on_body_entered(body):
	if body.name=="Player":
		GameManager.add_timber(1)
		GameManager.hotbar_changed.emit()
		queue_free()
	

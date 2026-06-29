extends Area3D


@export var item_id:String="sword_iron"

func _on_body_entered(body):
	if body.name=="Player":
		GameManager.add_item(item_id,name)
		queue_free()

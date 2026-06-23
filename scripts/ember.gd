extends Area3D




func _on_body_entered(body):
	if body.name=="Player":
		GameManager.collect_ember(name)
		queue_free()

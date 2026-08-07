extends Area3D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body):
	if body.name=="Player":
		GameManager.in_water=true
		body.current_water_surface_y=global_position.y
	elif "current_surface_y" in body:
		body.in_water=true
		body.current_surface_y=global_position.y
	
func _on_body_exited(body):
	if body.name=="Player":
		GameManager.in_water=false
	elif "current_surface_y" in body:
		body.in_water=false

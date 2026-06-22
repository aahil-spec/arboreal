extends DirectionalLight3D

@onready var world_env:Environment=$"../WorldEnvironment".environment
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	var angle=(GameManager.time_of_day/24.0)*360.0-90.0
	rotation_degrees.x=angle
	
	if GameManager.is_night():
		light_energy=0.1
		world_env.ambient_light_energy=0.2
	else:
		light_energy=1.2
		world_env.ambient_light_energy=1.0

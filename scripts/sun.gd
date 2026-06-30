extends DirectionalLight3D

@export var world_env: WorldEnvironment
# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	var time=GameManager.time_of_day
	var intensity=0.0
	
	if time>=6.0 and time<=8.0:
		intensity=(time-6.0)/2.0
	elif time>8.0 and time<18.0:
		intensity=1.0
	elif time>=18.0 and time<=20.0:
		intensity=1.0-((time-18.0)/2.0)
	else:
		intensity=0.0
		
	rotation_degrees.x=lerp(-90.0,-270.0,time/24.0)
	
	light_color=Color("1b2234").lerp(Color("ffffff"),intensity)
	light_energy=lerp(0.2,1.0,intensity)
	
	if world_env and world_env.environment:
		world_env.environment.background_energy_multiplier = lerp(0.3, 1.0, intensity)
		world_env.environment.ambient_light_energy = lerp(0.4, 1.0, intensity)

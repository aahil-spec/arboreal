extends Node

var embers_collected:int=0
var has_built_shelter:bool=false
var timber:int=0
var time_of_day:float=300.0

const DAY_LENGTH_SECONDS:float=300.0

func _process(delta):
	time_of_day+=(24.0/DAY_LENGTH_SECONDS)*delta
	if time_of_day>=24.0:
		time_of_day-=24.0
		
func is_night() ->bool:
	return time_of_day<6.0 or time_of_day>20.0
func collect_ember():
	embers_collected+=1

func add_timber(amount:int):
	timber+=amount
	
func spend_timber(amount:int) ->bool:
	if timber>=amount:
		timber-=amount
		return true
	return false
	

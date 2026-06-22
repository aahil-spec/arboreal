extends Node

var embers_collected:int=0
var has_built_shelter:bool=false
var timber:int=0

func collect_ember():
	embers_collected+=1

func add_timber(amount:int):
	timber+=amount
	print("Timber:",timber)
	
func spend_timber(amount:int) ->bool:
	if timber>=amount:
		timber-=amount
		return true
	return false
	

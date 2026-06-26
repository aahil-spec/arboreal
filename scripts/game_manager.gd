extends Node

var embers_collected:int=0
var collected_ember_names:Array=[]
var has_built_shelter:bool=false
var timber:int=0
var collected_timber_names:Array=[]
var placed_pieces:Array=[]
var time_of_day:float=300.0
var player_health:int=100 
var build_mode:bool=false
var player_invincible:bool=false
var shrine_lit:bool=false
var husk_defeated:bool=false 
var is_raining:bool=false
var rain_check_timer:float=30.0
const MAX_PLAYER_HEALTH:int=100
const DAY_LENGTH_SECONDS:float=300.0

signal player_damaged
func _process(delta):
	time_of_day+=(24.0/DAY_LENGTH_SECONDS)*delta
	if time_of_day>=24.0:
		time_of_day-=24.0
	rain_check_timer-=delta
	if rain_check_timer<=0.0:
		rain_check_timer=30.0
		if not is_raining and randf()<0.3:
			is_raining=true
		elif is_raining and randf()<0.3:
			is_raining=false
		
func is_night() ->bool:
	return time_of_day<6.0 or time_of_day>20.0
	
func collect_ember(ember_name:String=""):
	embers_collected+=1
	if ember_name!="":
		collected_ember_names.append(ember_name)

func add_timber(amount: int, pickup_name: String = ""):
	timber += amount
	if pickup_name != "":
		collected_timber_names.append(pickup_name)
	print("Timber: ", timber)
	
func spend_timber(amount:int) ->bool:
	if timber>=amount:
		timber-=amount
		return true
	return false
	
func record_pieces(piece_name:String,position:Vector3,rotation:Vector3):
	placed_pieces.append({
		"name":piece_name,
		"position":{"x":position.x,"y":position.y,"z":position.z},
		"rotation":{"x":rotation.x,"y":rotation.y,"z":rotation.z}
	})
func damage_player(amount:int):
	if player_invincible:
		return
	player_health-=amount
	if player_health<0:
		player_health=0
	player_damaged.emit()
		
func heal_player(amount:int):
	player_health=min(player_health+amount,MAX_PLAYER_HEALTH)

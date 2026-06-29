extends Node

signal player_damaged

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

var items:Dictionary={
	"sword_iron":{"name":"Iron Sword","type":"weapon","bonus_key":"attack_damage","bonus_value":10},
	"sword_ember":{"name":"Ember Blade","type":"weapon","bonus_key":"attack_damage","bonus_value":25},
	"armor_leather":{"name":"Leather Armor","type":"armor","bonus_key":"defense","bonus_value":5},
	"boots_swift":{"name":"Swift Boots","type":"boots","bonus_key":"speed_bonus","bonus_value":1.0},
}

var inventory:Array=[]
var equipped:Dictionary={"weapon":"","armor":"","boots":""}
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
	var reduced=max(amount-get_defense(),1)
	player_health-=reduced
	if player_health<0:
		player_health=0
	player_damaged.emit()
		
func heal_player(amount:int):
	player_health=min(player_health+amount,MAX_PLAYER_HEALTH)
	
func add_item(item_id:String):
	inventory.append(item_id)
	print("Picked up: ", items[item_id]["name"])
	
func equip_item(item_id:String):
	var item_type=items[item_id]["type"]
	equipped[item_type]=item_id
	print("Equipped: ", items[item_id]["name"])
	
func get_attack_damage():
	var base=15
	if equipped["weapon"] !="" and items[equipped["weapon"]]["bonus_key"]=="attack_damage":
		base+=items[equipped["weapon"]]["bonus_value"]
	return base
		
func get_defense():
	var defense=0
	if equipped["armor"]!=""and items[equipped["armor"]]["bonus_key"]=="defense":
		defense+=items[equipped["armor"]]["bonus_value"]
	return defense
		
func get_speed_bonus():
	var bonus=0.0
	if equipped["boots"] !=""and items[equipped["boots"]]["bonus_key"]=="speed_bonus":
		bonus+=items[equipped["boots"]]["bonus_value"]
	return bonus

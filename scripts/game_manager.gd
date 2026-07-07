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
var collected_item_pickup_names:Array=[]
var rain_check_timer:float=30.0
const MAX_PLAYER_HEALTH:int=100
const DAY_LENGTH_SECONDS:float=300.0

var items:Dictionary={
	"sword_iron":{"name":"Iron Sword","type":"weapon","bonus_key":"attack_damage","bonus_value":10},
	"sword_ember":{"name":"Ember Blade","type":"weapon","bonus_key":"attack_damage","bonus_value":25},
	"armor_leather":{"name":"Leather Armor","type":"armor","bonus_key":"defense","bonus_value":5},
	"boots_swift":{"name":"Swift Boots","type":"boots","bonus_key":"speed_bonus","bonus_value":1.0},
	"raw_meat_bundle":{"name":"Raw Meat","type":"ingredient","bonus_key":"none","bonus_value":0},
	"torch_extra":{"name":"Spare Torch","type":"ingredient","bonus_key":"none","bonus_value":0},
	"helmet_leather":{"name":"Leather Helmet","type":"helmet","bonus_key":"defense","bonus_value":3},
	"leggings_leather":{"name":"Leather Leggings","type":"leggings","bonus_key":"defense","bonus_value":4},
	"shield_wood":{"name":"Wooden Shield","type":"offhand","bonus_key":"defense","bonus_value":6},
	"bandage": {"name": "Bandage", "type": "consumable", "bonus_key": "health", "bonus_value": 20},
	"fiber": {"name": "Fiber", "type": "material", "bonus_key": "none", "bonus_value": 0},
	"timber": {"name": "Timber", "type": "material", "bonus_key": "none", "bonus_value": 0},
}

var inventory:Array=[]
var equipped:Dictionary={"weapon":"","offhand":"","armor":"","leggings":"","helmet":"","boots":""}

var hunger:float=100.0
var thirst:float=100.0
const MAX_HUNGER:float=100.0
const MAX_THRIST:float=100.0
const HUNGER_DRAIN_PER_SECOND:float=100.0/720.0
const THRIST_DRAIN_PER_SECOND:float=100.0/480.0
var survival_damage_timer:float=1.0

var stamina:float=100.0
const MAX_STAMINA:float=100.0
const STAMINA_DRAIN_PER_SECOND:float=15.0
const STAMINA_REGEN_PER_SECOND:float=3.0
var is_sprinting:bool=false

var collected_berry_names:Array=[]

var warmth:float=100.0
const MAX_WARMTH:float=100.0
const WARMTH_DRAIN_PER_SECOND:float=100.0/300.0
const WARMTH_REGEN_PER_SECOND:float=100.0/120.0
var is_sheltered:bool=false
var near_heat_source:bool=false

var fiber:int=0
var collected_fiber_names:Array=[]


var in_water:bool=false
var water_y_level:float=-3.0

var breath:float=100.0
const MAX_BREATH:float=100.0
const BREATH_DRAIN_PER_SECOND:float=100.0/30.0
const BREATH_REGEN_PER_SECOND:float=100.0/8.0
var drown_timer:float=1.0

var active_hotbar_slot:int=0
signal hotbar_changed
var recipes:Dictionary={
	"armor_leather":{"timber":0,"fiber":8,"meat":0},
	"boots_swift":{"timber":4,"fiber":4,"meat":0},
	"torch_extra":{"timber":2,"fiber":2,"meat":0},
	"helmet_leather":{"timber":0,"fiber":5,"meat":0},
	"leggings_leather":{"timber":0,"fiber":5,"meat":0},
	"shield_wood":{"timber":4,"fiber":2,"meat":0},
	"bandage":{"timber":0,"fiber":3,"meat":0},
}

var item_icons: Dictionary = {
	"sword_iron": "res://assets/icons/sword_iron.png",
	"fiber": "res://assets/icons/fiber.png",
	"timber": "res://assets/icons/timber.png",
	"armor_leather": "res://assets/icons/armor_leather.png",
	"boots_swift": "res://assets/icons/boots_swift.png",
	"raw_meat_bundle": "res://assets/icons/raw_meat.png", 
	"torch_extra": "res://assets/icons/torch_extra.png", 
	"helmet_leather": "res://assets/icons/helmet_leather.png", 
	"leggings_leather": "res://assets/icons/leggings_leather.png",
	"shield_wood": "res://assets/icons/shield_wood.png", 
	"bandage": "res://assets/icons/bandage.png",
}

var item_models:Dictionary={
	"sword_iron":"res://scenes/pieces/sword_iron.tscn",
	"timber": "res://scenes/pieces/timber_pickup.tscn",
	"torch_extra": "res://scenes/pieces/torch_3d.tscn",
	"helmet_leather":"res://scenes/pieces/helmet_leather.tscn",
	"armor_leather":"res://scenes/pieces/armor_leather.tscn",
	"boots_swift":"res://scenes/pieces/boots_swift.tscn",
	"leggings_leather":"res://scenes/pieces/leggings_leather.tscn",
	"fiber":"res://scenes/pieces/fiber_bush.tscn",
}
func _ready():
	inventory.clear()
	add_to_inventory("fiber",3)
	add_to_inventory("sword_iron",1)
	add_to_inventory("helmet_leather",1)
	
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
	
	hunger=max(hunger-HUNGER_DRAIN_PER_SECOND*delta,0.0)
	thirst=max(thirst-THRIST_DRAIN_PER_SECOND*delta,0.0)
	
	if is_sprinting and stamina>0.0:
		stamina=max(stamina-STAMINA_DRAIN_PER_SECOND*delta,0.0)
	else:
		stamina=min(stamina+STAMINA_REGEN_PER_SECOND*delta,MAX_STAMINA)
		
	var exposed=(is_night() or is_raining) and not is_sheltered and not near_heat_source
	if exposed:
		warmth=max(warmth-WARMTH_DRAIN_PER_SECOND*delta,0.0)
	else:
		warmth=min(warmth+WARMTH_REGEN_PER_SECOND*delta,MAX_WARMTH)
	if hunger <=0.0 or thirst<=0.0 or warmth<=0.0:
		survival_damage_timer-=delta
		if survival_damage_timer<=0.0:
			survival_damage_timer=1.0
			damage_player(2)
	if in_water:
		print(GameManager.in_water)
		breath=max(breath-BREATH_DRAIN_PER_SECOND*delta,0.0)
		if breath<=0.0:
			drown_timer-=delta
			if drown_timer<=0.0:
				drown_timer=1.0
				damage_player(5)
	else:
		breath=min(breath+BREATH_REGEN_PER_SECOND*delta,MAX_BREATH)
		drown_timer=1.0
		
	
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
	add_to_inventory("timber",amount)
	
	
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
	
func add_item(item_id:String,pickup_name:String=""):
	add_to_inventory(item_id,1)
	if pickup_name!="":
		collected_item_pickup_names.append(pickup_name)
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
	for slot in ["armor","leggings","helmet","offhand"]:
		var item_id=equipped[slot]
		if item_id!="" and items[item_id]["bonus_key"]=="defense":
			defense+=items[item_id]["bonus_value"]
	return defense
		
func get_speed_bonus():
	var bonus=0.0
	if equipped["boots"] !=""and items[equipped["boots"]]["bonus_key"]=="speed_bonus":
		bonus+=items[equipped["boots"]]["bonus_value"]
	return bonus

func eat(amount:float,pickup_name:String=""):
	hunger=min(hunger+amount,MAX_HUNGER)
	if pickup_name!="":
		collected_berry_names.append(pickup_name)
		
func drink(amount:float):
	thirst=min(thirst+amount,MAX_THRIST)
func add_fiber(amount:int,pickup_name:String=""):
	fiber+=amount
	if pickup_name!="":
		collected_fiber_names.append(pickup_name)
	add_to_inventory("fiber",amount)

func spend_fiber(amount:int):
	if fiber>=amount:
		fiber-=amount
		return true
	return false

func can_craft(item_id:String):
	var cost=recipes[item_id]
	return timber >= cost["timber"] and fiber >= cost["fiber"] and _count_meat() >= cost["meat"]
func _count_meat():
	var count=0
	for item in inventory:
		if item=="raw_meat_bundle":
			count+=1
	return count
	
	
func craft_item(item_id:String):
	if not can_craft(item_id):
		return false
	var cost=recipes[item_id]
	timber-=cost["timber"]
	fiber-=cost["fiber"]
	
	remove_from_inventory("timber",cost["timber"])
	remove_from_inventory("fiber",cost["fiber"])
	
	for i in range(cost["meat"]):
		remove_from_inventory("raw_meat_bundle",1)
	add_to_inventory(item_id,1)
	return true
func add_to_inventory(item_id:String,amount:int=1):
	var max_stack=80
	if items[item_id]["type"] in ["weapon","helmet","armor","leggings","boots","offhand"]:
		max_stack=1
		
	var remaining =amount
	
	for i in range(inventory.size()):
		if inventory[i] is Dictionary and inventory[i]["id"]==item_id and inventory[i]["count"] <max_stack:
			var space=max_stack-inventory[i]["count"]
			if remaining<=space:
				inventory[i]["count"]+=remaining
				remaining=0
				break
			else:
				inventory[i]["count"]=max_stack
				remaining-=space
	while remaining>0:
		var chunk=min(remaining,max_stack)
		inventory.append({"id":item_id,"count":chunk})
		remaining-=chunk
		
func remove_from_inventory(item_id:String,amount:int):
	var remaining=amount
	for i in range(inventory.size()-1,-1,-1):
		if inventory[i] is Dictionary and inventory[i]["id"]==item_id:
			if inventory[i]["count"]>remaining:
				inventory[i]["count"]-=remaining
				remaining=0
				break
			else:
				remaining-=inventory[i]["count"]
				inventory.remove_at(i)
		if remaining<=0:
			break
			

func get_acitve_hotbar_item()-> Dictionary:
	if active_hotbar_slot<inventory.size():
		var item=inventory[active_hotbar_slot]
		if item is Dictionary:
			return item
	return{}

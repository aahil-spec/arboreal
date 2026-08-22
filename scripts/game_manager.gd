extends Node

signal quest_alert(quest_title:String)
signal player_damaged

var embers_collected:int=0
var collected_ember_names:Array=[]
var has_built_shelter:bool=false
var timber:int=0
var collected_timber_names:Array=[]
var placed_pieces:Array=[]

var time_of_day:float=12.0
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
	"emberwing":{"name":"Emberwing","type":"wings","bonus_key":"none","bonus_value":0},
}

var inventory:Array=[]
var equipped:Dictionary={"weapon":"","offhand":"","armor":"","leggings":"","helmet":"","boots":"","wings":""}

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

var breath:float=100.0
const MAX_BREATH:float=100.0
const BREATH_DRAIN_PER_SECOND:float=100.0/30.0
const BREATH_REGEN_PER_SECOND:float=100.0/8.0
var drown_timer:float=1.0

var active_hotbar_slot:int=0

var shop_open:bool=false

var discovered_locations:Array=[]

signal hotbar_changed
signal inventory_changed
signal quest_completed_signal(quest_title)

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
	"emberwing":"res://assets/icons/emberwing.png"
}

var item_models:Dictionary={
	"sword_iron":"res://scenes/pieces/sword_iron.scn",
	"timber": "res://scenes/pieces/timber_pickup.tscn",
	"torch_extra":"res://scenes/torch_extra.tscn" ,
	"helmet_leather":"res://scenes/pieces/helmet_leather.tscn",
	"armor_leather":"res://scenes/pieces/armor_leather.tscn",
	"boots_swift":"res://scenes/pieces/boots_swift.tscn",
	"leggings_leather":"res://scenes/pieces/leggings_leather.tscn",
	"fiber":"res://scenes/pieces/fiber_bush.tscn",
	"emberwing":"res://scenes/ember_wings.tscn",
	"bandage":"res://models/bandage.tscn",
	"shield_wood":"res://scenes/wooden_shield.tscn",
}

var active_quests:Array=[]
var completed_quests:Array=[]

var quest_definitions:Dictionary={
	"find_embers":{
		"title":"Relight the Shrine",
		"description":"Find the 3 ancient embers hidden in the ruins.",
		"objectives":[
			{"text":"Collect ember 1","type":"collect_ember","target":1},
			{"text":"Collect ember 2","type":"collect_ember","target":2},
			{"text":"Collect ember 3","type":"collect_ember","target":3},
			{"text":"Light the shrine","type":"light_shrine","target":1},
		],
		"reward_timber":50,
		"reward_item":"sword_iron",
		"giver":"Hermit"
	},
	"explore_ashen_hollow":{
		"title":"Investigate the Hollow",
		"description":"The Hermit noticed something stirring north in the Ashen Hollow. Go find out what woke up.",
		"objectives":[
			{"text":"Discover the Ashen Hollow","type":"discover_location","target":"Ashen Hollow"},
		],
		"reward_timber":30,
		"reward_item":"bandage",
		"giver":"Hermit"
	},
	"defeat_husk":{
		"title":"The Husk",
		"description":"Final Battle",
		"objectives":[
			{"text":"Defeat the Husk","type":"defeat_husk","target":1},
		],
		"reward_timber":80,
		"reward_item":"armor_leather",
		"giver":"Hermit"
	},
	"clear_bandits":{
		"title":"Bandit Trouble",
		"description":"The village has been asking someone to deal with the bandits to the north.",
		"objectives":[
			{"text":"Defeat 3 bandit guards","type":"defeat_bandits","target":3},
			
		],
		"reward_timber":60,
		"reward_item":"boots_swift",
		"giver":"Village Elder"
	},
	"gather_supplies":{
		"title":"Winter Stores",
		"description":"Help the fisherman gather supplies before the cold sets in.",
		"objectives":[
			{"text":"Collect 10 Timber","type":"have_timber","target":10},
			{"text":"Collect 5 Fiber","type":"have_fiber","target":5},
			{"text":"Hunt 2 deer","type":"hunt_deer","target":2},
		],
		"reward_timber":40,
		"reward_item":"bandage",
		"giver":"Fisherman"
	},
}

var chronicle_pages:Array=[
	{
		"id":"page_1",
		"title":"The Valley of Arboreal",
		"unlock_condition":"always",
		"text":"Long before thw Sundering,Arboreal was said to burn bright through even the darkest winters. The old shrine at the valley's heart drew its warmth from something older than the kingdom itself - a light that never asked for anything but tending.\n\nThen, one winter, it simply went out. No one alive remembers why."
	},
	{
		"id":"page_2",
		"title":"The Shaper's Gift",
		"unlock_condition":"embers_collected_1",
		"text":"Few are born with the sense for it - a faint pull toward embers, as though the light itself recognizes something in you. The old texts call it the Shaper's gift. Most who have it never learn what it means.\n\nYou are one of the few. Whether that is fortune or burden, the valley has not yet decided. "
	},
	{
		"id":"page_3",
		"title":"The Three Embers",
		"unlock_condition":"embers_collected_3",
		"text":"The shrine did not simply go dark - its light scattered, three fragments carried into ruin by forces no one recorded. To religion it is not to restore what was, but to gather what was lost.\n\nYou have done what the last Shaper could not finish."
		
	},
	{
		"id":"page_4",
		"title":"What the Light Remembers",
		"unlock_condition":"shrine_lit",
		"text":"The shrine burns again. For the first time in a generation, Arboreal Village will see true warmth through the night. The Hermit, who has tended the dead shrine for longer than anyone can say , finally allows himself to hope.\n\nBut light this old does not return withouth waking something else."
		
	},
	{
		"id":"page_5",
		"title":"The Ashen Hollow",
		"unlock_condition":"discovered_ashen_hollow",
		"text":"North of the valley, where the ground turns to ash and the trees no longer grow, something has stirred that the old texts warn against naming directly. Th Hollow that scavenge at night are one thing. What sleeps beneath the Ashen Hollow is another."
		
	},
	{
		"id":"page_6",
		"title":"The Husk",
		"unlock_condition":"husk_defeated",
		"text":"It is done. What woke when the shrine relit has fallen. The valley does not yet know how close it came to a second Sundering - and perhaps it never needs to.\n\nThe blade you carry now was not made by any smith in Arboreal. It remembers something the valley has forgotten."
		
	},
	{
		"id":"page_7",
		"title":"Gravity's Wound",
		"unlock_condition":"discovered_gravity_zone",
		"text":"There is a place in the high forest where the old texts simply stop making sense - where down is a matter of opinion, and the trees grow toward a floor that is not there. No one has ever explained it. The Hermit calls it a wound in the world, left over from whatever first Sundered the valley."
		
	},
	{
		"id":"page_8",
		"title":"The Emberwing",
		"unlock_condition":"has_emberwing",
		"text":"Wings that were never grown, only found - waiting in a place gravity itself had forgotten how to hold down. Whoever left them there is not recorded in any text of Arboreal.\n\nYou wear them now. The valley looks smaller from above than anyone standing in it could ever guess. "
	}
]

var chronicle_last_page:int=0
var quest_progress:Dictionary={}

var in_gravity_zone:bool=false

var player_name:String="Traveler"

var settings_return_scene:String="res://scenes/main_menu.tscn"

var flight_energy:float=100.0
const MAX_FLIGHT_ENERGY:float=100.0
const FLIGHT_DRAIN_PER_SECOND:float=100.0/45.0
const FLIGHT_REGEN_PER_SECOND:float=100.0/12.0
var is_flying:bool=false


var chronicle_notified_pages:Array=[]
const DROPPED_ITEM_SCENE=preload("res://scenes/dropped_item.tscn")

func _ready():
	inventory.clear()
	
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
	update_quest_progress("collect_ember")
	check_chronicle_unlocks()
	
	if embers_collected==3:
		quest_alert.emit("Tip: Find the Shrine and light it")
		
func add_timber(amount: int, pickup_name: String = ""):
	timber += amount
	if pickup_name != "":
		collected_timber_names.append(pickup_name)
	add_to_inventory("timber",amount)
	
	
func spend_timber(amount:int) ->bool:
	if timber>=amount:
		timber-=amount
		inventory_changed.emit()
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
	player_damaged.emit()
	
func add_item(item_id:String,pickup_name:String=""):
	add_to_inventory(item_id,1)
	if pickup_name!="":
		collected_item_pickup_names.append(pickup_name)
	print("Picked up: ", items[item_id]["name"])
	hotbar_changed.emit()
	
func equip_item(item_id:String):
	var item_type=items[item_id]["type"]
	equipped[item_type]=item_id
	print("Equipped: ", items[item_id]["name"])
	GameManager.check_chronicle_unlocks()
	
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
		inventory_changed.emit()
		return true
	return false

func can_craft(item_id:String):
	var cost=recipes[item_id]
	return timber >= cost["timber"] and fiber >= cost["fiber"] and _count_meat() >= cost["meat"]
func _count_meat():
	var count=0
	for item in inventory:
		if item is Dictionary and item.get("id")=="raw_meat_bundle":
			count+=item.get("count",1)
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
		if inventory[i] is Dictionary and inventory[i].has("id") and inventory[i]["id"]==item_id and inventory[i]["count"] <max_stack:
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
	inventory_changed.emit()
		
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
	inventory_changed.emit()

func get_acitve_hotbar_item()-> Dictionary:
	if active_hotbar_slot<inventory.size():
		var item=inventory[active_hotbar_slot]
		if item is Dictionary and item.has("id"):
			return item
	return{}

func start_quest(quest_id:String):
	if quest_id in active_quests or quest_id in completed_quests:
		return
	active_quests.append(quest_id)
	quest_progress[quest_id]={}
	var title=quest_definitions[quest_id]["title"]
	print("Quest started:",quest_definitions[quest_id]["title"])
	quest_alert.emit(title)
func update_quest_progress(objective_type:String,value=1):
	for quest_id in active_quests:
		var quest =quest_definitions[quest_id]
		for objective in quest["objectives"]:
			if objective["type"]==objective_type:
				var current=quest_progress[quest_id].get(objective_type,0)
				quest_progress[quest_id][objective_type]=current+value
				_check_quest_completion(quest_id)
				break
				
func _check_quest_completion(quest_id:String):
	var quest =quest_definitions[quest_id]
	var progress=quest_progress[quest_id]
	for objective in quest["objectives"]:
		var current=progress.get(objective["type"],0)
		if objective["type"] in ["discover_location"]:
			if not (objective["target"] in discovered_locations):
				return
		elif current<objective["target"]:
			return
		_complete_quest(quest_id)
		
func _complete_quest(quest_id:String):
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	var quest = quest_definitions[quest_id]
	timber+=quest["reward_timber"]
	add_item(quest["reward_item"])
	print("Quest complete:",quest["title"],"! Rewards given.")
	quest_completed_signal.emit(quest["title"])
	
func has_wings():
	return equipped["wings"]=="emberwing"
func spawn_drop(item_id:String,world_position:Vector3):
	var drop=DROPPED_ITEM_SCENE.instantiate()
	drop.item_id=item_id
	drop.position=world_position+Vector3(0,0.4,0)
	get_tree().current_scene.add_child(drop)
func has_item(target_id:String):
	for item in inventory:
		if item is Dictionary and item.has("id") and item["id"]==target_id:
			return true
	return false
func is_page_unlocked(page:Dictionary):
	var condition=page["unlock_condition"]
	match condition:
		"always":
			return true
		"embers_collected_1":
			return embers_collected>=1
		"embers_collected_3":
			return embers_collected>=3
		"shrine_lit":
			return shrine_lit
		"discovered_ashen_hollow":
			return "Ashen Hollow" in discovered_locations
		"husk_defeated":
			return husk_defeated
		"discovered_gravity_zone":
			return in_gravity_zone or "gravity_zone_visited" in discovered_locations
		"has_emberwing":
			return equipped.get("wings","")=="emberwing" or "emberwing" in inventory
		_:
			return false
			
		
func check_chronicle_unlocks():
	for page in chronicle_pages:
		if is_page_unlocked(page) and page["id"] not in chronicle_notified_pages:
			chronicle_notified_pages.append(page["id"])
			_show_chronicle_notification(page["title"])
			
func _show_chronicle_notification(title:String):
	await get_tree().create_timer(6.5).timeout
	quest_alert.emit("Lore:"+ title)

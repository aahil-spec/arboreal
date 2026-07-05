extends Panel

@onready var helmet_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/HelmetSlot
@onready var armor_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/ArmorSlot
@onready var leggings_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/LeggingsSlot
@onready var boots_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/BootsSlot
@onready var weapon_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/WeaponSlot
@onready var offhand_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/OffhandSlot


@onready var crafting_grid:GridContainer=$MainLayout/RightPanel/VBoxContainer/CraftingGrid
@onready var craft_output_slot:Panel=$MainLayout/RightPanel/VBoxContainer/CraftOutputSlot
@onready var held_display:Panel=$HeldItemDisplay
@onready var tooltip_label:Label=$ToolTipLabel
@onready var inventory_grid:GridContainer=$MainLayout/LeftPanel/VBoxContainer/InventoryGrid

var craft_grid_items:Array=["","","","","","","",""]
var craft_result:String=""
var equip_slot_map:Dictionary={}


const INV_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const CRAFT_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const MAX_INV_SLOTS=48

var inv_slot_nodes:Array=[]
var craft_grid_slots:Array=[]
var held_item:String=""
var held_item_source:String=""
var held_item_source_index:int=-1



func _ready():
	_build_inventory_grid()
	_build_equip_slot_map()
	_build_crafting_grid()

@warning_ignore("unused_parameter")
func _process(delta):
	if held_item!="":
		held_display.visible=true
		held_display.global_position=get_viewport().get_mouse_position()-Vector2(28,28)
		var icon=held_display.get_node("Icon")
		if GameManager.item_icons.has(held_item):
			icon.texture=load(GameManager.item_icons[held_item])
	else:
		held_display.visible=false
	
func _build_inventory_grid():
	for i in range(MAX_INV_SLOTS):
		var slot = INV_SLOT.instantiate()
		slot.slot_index=i
		slot.slot_clicked.connect(_on_inv_slot_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		inventory_grid.add_child(slot)
		inv_slot_nodes.append(slot)
		
		
@warning_ignore("unused_parameter")
func _on_inv_slot_clicked(index: int, button: int):
	if button==MOUSE_BUTTON_LEFT:
		if held_item=="":
			if index<GameManager.inventory.size():
				held_item=GameManager.inventory[index]
				held_item_source="inventory"
				held_item_source_index=index
				GameManager.inventory.remove_at(index)
				refresh_inventory()
		else:
			var item_type=GameManager.items[held_item]["type"]
			if GameManager.equipped.has(item_type) and index>=GameManager.inventory.size():
				GameManager.equip_item(held_item)
			else:
				GameManager.inventory.insert(index,held_item)
			held_item=""
			held_item_source=""
			held_item_source_index=-1
			refresh_all()
			
@warning_ignore("unused_parameter")
func _on_slot_hovered(index: int):
	pass
func _on_slot_unhovered():
	pass

func _build_equip_slot_map():
	equip_slot_map={
		"helmet":helmet_slot,
		"armor":armor_slot,
		"leggings":leggings_slot,
		"boots":boots_slot,
		"weapon":weapon_slot,
		"offhand":offhand_slot,
	}
	for slot_type in equip_slot_map:
		var slot_node=equip_slot_map[slot_type]
		slot_node.slot_clicked.connect(_on_equip_slot_clicked.bind(slot_type))
		slot_node.slot_hovered.connect(_on_equip_slot_hovered.bind(slot_type))
		slot_node.slot_unhovered.connect(_on_slot_unhovered)

func refresh_equipment():
	for slot_type in equip_slot_map:
		var slot_node = equip_slot_map[slot_type]
		var icon_node = slot_node.get_node("Icon")
		icon_node.texture = null
		var item_id = GameManager.equipped[slot_type]
		if item_id!="" and GameManager.item_icons.has(item_id):
			icon_node.texture = load(GameManager.item_icons[item_id])
		_set_slot_border(slot_node,item_id!="")
	
	
@warning_ignore("unused_parameter")
func _on_equip_slot_clicked(index:int,button:int,slot_type:String):
	var item_id=GameManager.equipped[slot_type]
	if item_id!="":
		GameManager.equipped[slot_type]=""
		GameManager.inventory.append(item_id)
		refresh_all()
	
@warning_ignore("unused_parameter")
func _on_equip_slot_hovered(index:int,slot_type:String):
	var item_id=GameManager.equipped[slot_type]
	if item_id!="":
		_show_tooltip(item_id)
		
func _set_slot_border(slot:Panel,active:bool):
	var style=StyleBoxFlat.new()
	style.bg_color=Color(0.22,0.22,0.22)
	style.set_corner_radius_all(2)
	if active:
		style.border_color=Color(1,0.85,0.1)
		style.set_border_width_all(3)
	else:
		style.border_color=Color(0.4,0.4,0.4)
		style.set_border_width_all(2)
	slot.add_theme_stylebox_override("panel",style)
	
func refresh_all():
	refresh_inventory()
	refresh_equipment()
	refresh_crafting()
@warning_ignore("unused_parameter")
func _show_tooltip(item_id:String):
	pass
	
	
func _build_crafting_grid():
	for i in range(9):
		var slot=CRAFT_SLOT.instantiate()
		slot.slot_index=i
		slot.slot_clicked.connect(_on_craft_slot_clicked)
		slot.slot_hovered.connect(_on_craft_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		crafting_grid.add_child(slot)
		craft_grid_slots.append(slot)
	craft_output_slot.slot_clicked.connect(_on_output_slot_clicked)
	craft_output_slot.slot_hovered.connect(_on_output_slot_hovered)
	craft_output_slot.slot_unhovered.connect(_on_slot_unhovered)
func _on_craft_slot_clicked(index:int,button:int):
	if button==MOUSE_BUTTON_LEFT:
		if held_item=="":
			if craft_grid_items[index] !="":
				held_item=craft_grid_items[index]
				held_item_source="craft"
				held_item_source_index=index
				craft_grid_items[index]=""
				_check_craft_recipe()
				refresh_crafting()
		else:
			if craft_grid_items[index]!="":
				var swapped=craft_grid_items[index]
				craft_grid_items[index]=held_item
				held_item=swapped
			else:
				craft_grid_items[index]=held_item
				held_item=""
				held_item_source=""
				held_item_source_index=-1
			_check_craft_recipe()
			refresh_crafting()
				
@warning_ignore("unused_parameter")
func _on_output_slot_clicked(index:int,button:int):
	if craft_result !="" and held_item=="":
		held_item=craft_result
		held_item_source="output"
		held_item_source_index=-1
		for i in range(9):
			if craft_grid_items[i] !="":
				craft_grid_items[i]=""
				break
		craft_result=""
		_check_craft_recipe()
		refresh_crafting()
	elif held_item !="" and craft_result=="":
		GameManager.inventory.append(held_item)
		held_item=""
		refresh_all()
		
var craft_recipes:Dictionary={
	"armor_leather":[
		["fiber","fiber","fiber"],
		["fiber","","fiber"],
		["fiber","fiber","fiber"]
	],
	"boots_swift":[
		["","",""],
		["timber","","timber"],
		["fiber","","fiber"]
	],
	"helmet_leather":[
		["fiber","fiber","fiber"],
		["fiber","","fiber"],
		["", "", ""]
		
	],
	"leggings_leather":[
		["fiber","fiber","fiber"],
		["fiber","","fiber"],
		["fiber","","fiber"]
		
	],
	"shield_wood":[
		["timber","timber",""],
		["timber","fiber",""],
		["timber","timber",""]
	],
	"torch_extra":[
		["","timber",""],
		["","fiber",""],
		["","",""]
	],
	"bandage":[
		["fiber","fiber",""],
		["fiber","",""],
		["","",""]
	]
}
func _check_craft_recipe():
	craft_result=""
	var grid=craft_grid_items
	for item_id in craft_recipes:
		var pattern=craft_recipes[item_id]
		var match_found=true
		for row in range(3):
			for col in range(3):
				var expected=pattern[row][col]
				var actual_item=grid[row*3+col]
				var actual_type=""
				if actual_item !="":
					actual_type=actual_item.split("_")[0]
				if expected !=actual_type and expected!=actual_item:
					match_found=false
					break
			if not match_found:
				break
		if match_found:
			craft_result=item_id
			break

func refresh_inventory():
	for i in range(MAX_INV_SLOTS):
		var slot=inv_slot_nodes[i]
		var icon_node=slot.get_node("Icon")
		icon_node.texture=null
		_set_slot_border(slot,false)
		if i<GameManager.inventory.size():
			var item_id=GameManager.inventory[i]
			if GameManager.item_icons.has(item_id):
				icon_node.texture=load(GameManager.item_icons[item_id])
				
func refresh_crafting():
	for i in range(9):
		var slot =craft_grid_slots[i]
		var icon_node=slot.get_node("Icon")
		icon_node.texture=null
		if craft_grid_items[i] !="":
			var item_id=craft_grid_items[i]
			if GameManager.item_icons.has(item_id):
				icon_node.texture=load(GameManager.item_icons[item_id])
	var out_icon=craft_output_slot.get_node("Icon")
	out_icon.texture=null
	if craft_result != "" and GameManager.item_icons.has(craft_result):
		out_icon.texture=load(GameManager.item_icons[craft_result])
		
@warning_ignore("unused_parameter")
func _on_craft_slot_hovered(index:int):
	pass
	
@warning_ignore("unused_parameter")
func _on_output_slot_hovered(index:int):
	pass

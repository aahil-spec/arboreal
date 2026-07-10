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
@onready var inventory_grid: GridContainer = $MainLayout/LeftPanel/InvScrollContainer/InventoryGrid

var craft_grid_items:Array=[{}, {}, {}, {}, {}, {}, {}, {}, {}]
var craft_result:String=""
var equip_slot_map:Dictionary={}


const INV_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const CRAFT_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const MAX_INV_SLOTS=48

var inv_slot_nodes:Array=[]
var craft_grid_slots:Array=[]
var held_item:Dictionary={}
var held_item_source:String=""
var held_item_source_index:int=-1



func _ready():
	inventory_grid.columns=6
	
	_build_inventory_grid()
	_build_equip_slot_map()
	_build_crafting_grid()
	call_deferred("refresh_all")
@warning_ignore("unused_parameter")
func _process(delta):
	if not held_item.is_empty():
		held_display.visible=true
		held_display.global_position=get_viewport().get_mouse_position()-Vector2(28,28)
		var icon=held_display.get_node("Icon")
		var count_label=held_display.get_node("CountLabel")
		
		var item_id=held_item["id"]
		if GameManager.item_icons.has(item_id):
			var path=GameManager.item_icons[item_id]
			if ResourceLoader.exists(path):
				icon.texture=load(path)
		if held_item["count"]>1:
			count_label.text=str(held_item["count"])
		else:
			count_label.text=""
	else:
		held_display.visible=false
	if tooltip_label.visible:
		tooltip_label.global_position=get_viewport().get_mouse_position()+Vector2(15,15)
func _build_inventory_grid():
	inventory_grid.columns=6
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
		if held_item.is_empty():
			if index<GameManager.inventory.size():
				if GameManager.inventory[index] is Dictionary:
					held_item=GameManager.inventory[index].duplicate()
				held_item_source="inventory"
				held_item_source_index=index
				GameManager.inventory.remove_at(index)
				refresh_inventory()
		else:
			var item_type=GameManager.items[held_item["id"]]["type"]
			
			if index<GameManager.inventory.size():
				var target_item=GameManager.inventory[index] if GameManager.inventory[index] is Dictionary else{}
				
				if target_item["id"]==held_item["id"] and item_type not in ["weapon","helmet","armor","leggings","boots","offhand"]:
					var space=80-target_item["count"]
					if space>=held_item["count"]:
						target_item["count"]+=held_item["count"]
						held_item={}
					else:
						target_item["count"]=80
						held_item["count"]-=space
					refresh_all()
					return
					
				var swapped=target_item.duplicate()
				GameManager.inventory[index]=held_item.duplicate()
				held_item=swapped
				
			else:
				GameManager.inventory.append(held_item.duplicate())
				held_item={}
			held_item_source=""
			held_item_source_index=-1
			refresh_all()
		

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
		GameManager.hotbar_changed.emit()
	
@warning_ignore("unused_parameter")
func _on_equip_slot_clicked(index:int,button:int,slot_type:String):
	if button==MOUSE_BUTTON_LEFT:
		if held_item.is_empty():
			var item_id=GameManager.equipped[slot_type]
			if item_id!="":
				GameManager.equipped[slot_type]=""
				GameManager.inventory.append({"id":item_id,"count":1})
				refresh_all()
		else:
			var item_id=held_item["id"]
			var item_type=GameManager.items[item_id]["type"]
			if item_type==slot_type:
				var old_item_id=GameManager.equipped[slot_type]
				GameManager.equip_item(item_id)
				
				if old_item_id !="":
					held_item={"id":old_item_id,"count":1}
				else:
					held_item={}
					held_item_source=""
					held_item_source_index=-1
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
	GameManager.hotbar_changed.emit()
@warning_ignore("unused_parameter")
func _show_tooltip(item_id:String):
	var item=GameManager.items[item_id]
	var text=item["name"]+"\n"
	if item["bonus_key"] !="none":
		text+=item["bonus_key"].capitalize()+":+"+str(item["bonus_value"])
	print("HOVERING: ", text)
	tooltip_label.text=text
	tooltip_label.visible=true
	tooltip_label.global_position = get_viewport().get_mouse_position() + Vector2(14, -40)
	
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
		if held_item.is_empty():
			if not craft_grid_items[index].is_empty():
				held_item=craft_grid_items[index].duplicate()
				held_item_source="craft"
				held_item_source_index=index
				craft_grid_items[index]={}
				_check_craft_recipe()
				refresh_crafting()
		else:
			if not craft_grid_items[index].is_empty():
				var target=craft_grid_items[index]
				if target["id"]==held_item["id"]:
					var space=80-target["count"]
					if space>=held_item["count"]:
						target["count"]+=held_item["count"]
						held_item={}
					else:
						target["count"]=80
						held_item["count"]-=space
				else:
					var swapped=craft_grid_items[index]
					craft_grid_items[index]=held_item.duplicate()
					held_item=swapped
			else:
				craft_grid_items[index]=held_item.duplicate()
				held_item={}
			_check_craft_recipe()
			refresh_crafting()
			
	elif button==MOUSE_BUTTON_RIGHT:
		if not held_item.is_empty():
			var target=craft_grid_items[index]
			
			if target.is_empty():
				craft_grid_items[index]={"id":held_item["id"],"count":1}
				held_item["count"] -=1
			elif target["id"]==held_item["id"] and target["count"] <80:
				target["count"]+=1
				held_item["count"]-=1
			if held_item["count"]<=0:
				held_item={}
			_check_craft_recipe()
			refresh_crafting()
				
@warning_ignore("unused_parameter")
func _on_output_slot_clicked(index:int,button:int):
	if craft_result !="" and held_item.is_empty():
		held_item={"id":craft_result,"count":1}
		held_item_source="output"
		held_item_source_index=-1
		
		for i in range(9):
			if not craft_grid_items[i].is_empty():
				craft_grid_items[i]["count"]-=1
				if craft_grid_items[i]["count"]<=0:
					craft_grid_items[i]={}
		craft_result=""
		_check_craft_recipe()
		refresh_crafting()
	elif not held_item.is_empty() and craft_result=="":
		GameManager.inventory.append(held_item.duplicate())
		held_item={}
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
				var actual_dict=grid[row*3+col]
				var actual_item=""
				var actual_type=""
				if not actual_dict.is_empty():
					actual_item=actual_dict["id"]
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
		var count_label=slot.get_node("CountLabel")
		icon_node.texture=null
		count_label.text=""
		_set_slot_border(slot,false)
		if i<GameManager.inventory.size():
			var item=GameManager.inventory[i]
			if item is Dictionary and item.has("id"):
				var item_id=item["id"]
				if GameManager.item_icons.has(item_id):
					var path=GameManager.item_icons[item_id]
					if ResourceLoader.exists(path):
						icon_node.texture=load(path)
				if item["count"]>1:
					count_label.text=str(item["count"])
	GameManager.hotbar_changed.emit()
func refresh_crafting():
	for i in range(9):
		var slot =craft_grid_slots[i]
		var icon_node=slot.get_node("Icon")
		var count_label=slot.get_node("CountLabel")
		icon_node.texture=null
		count_label.text=""
		if not craft_grid_items[i].is_empty():
			var item=craft_grid_items[i]
			var item_id=item["id"]
			if GameManager.item_icons.has(item_id):
				var path=GameManager.item_icons[item_id]
				if ResourceLoader.exists(path):
					icon_node.texture=load(path)
					
			if item["count"]>1:
				count_label.text=str(item["count"])
	var out_icon=craft_output_slot.get_node("Icon")
	out_icon.texture=null
	if craft_result != "" and GameManager.item_icons.has(craft_result):
		out_icon.texture=load(GameManager.item_icons[craft_result])
	GameManager.hotbar_changed.emit()
func _on_slot_hovered(index:int):
	if index<GameManager.inventory.size():
		var item=GameManager.inventory[index]
		if item is Dictionary:
			
			_show_tooltip(item["id"])
func _on_slot_unhovered():
	tooltip_label.visible=false
	
func _on_craft_slot_hovered(index:int):
	if not craft_grid_items[index].is_empty():
		_show_tooltip(craft_grid_items[index]["id"])
		
@warning_ignore("unused_parameter")
func _on_output_slot_hovered(index:int):
	if craft_result!="":
		_show_tooltip(craft_result)

func _on_sort_button_pressed():
	GameManager.inventory.sort_custom(func(a,b):
		return GameManager.items[a["id"]]["type"]<GameManager.items[b["id"]]["type"]
	)
	refresh_inventory()

func _on_quick_craft_tab_pressed():
	$MainLayout/RightPanel/VBoxContainer/CraftingGrid.visible=false
	$MainLayout/RightPanel/QuickCraftPanel.visible=true

func _on_recycle_tab_pressed():
	$MainLayout/RightPanel/QuickCraftPanel.visible=false
	$MainLayout/RightPanel/VBoxContainer/CraftingGrid.visible=true

func _on_craft_torch_btn_pressed():
	if GameManager.craft_item("torch_extra"):
		refresh_all()


func _on_craft_bandage_btn_pressed():
	if GameManager.craft_item("bandage"):
		refresh_all()

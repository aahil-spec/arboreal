extends CanvasLayer

const INVENTORY_SLOT=preload("res://scenes/ui/inventory_slot.tscn")
const MAX_STORAGE_SLOTS=30

@onready var help_panel:Control=$HelpPanel
@onready var master_ui:HBoxContainer=$MasterInventoryUI
@onready var storage_grid:GridContainer=$MasterInventoryUI/StoragePanel/VBoxContainer/StorageGrid
@onready var crafting_list:VBoxContainer=$MasterInventoryUI/CraftingPanel/VBoxContainer/RecipeScroll/RecipeList

var storage_slot_nodes:Array=[]

func _ready():
	help_panel.visible=false
	master_ui.visible=false
	_build_storage_grid()
func _unhandled_input(event):
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible
	if event.is_action_pressed("toggle_inventory"):
		master_ui.visible=!master_ui.visible
		
		if master_ui.visible:
			_refresh_inventory()
			_refresh_crafting()
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			_refresh_inventory()

func _refresh_inventory():
	for i in range(MAX_STORAGE_SLOTS):
		var slot=storage_slot_nodes[i]
		slot.get_node("ItemIcon").texture=null
		slot.get_node("CountLabel").text=""
	
	for i in range(GameManager.inventory.size()):
		if i>=MAX_STORAGE_SLOTS:
			break
		var item_id=GameManager.inventory[i]
		var slot=storage_slot_nodes[i]
		
		if GameManager.item_icons.has(item_id):
			slot.get_node("ItemIcon").texture=load(GameManager.item_icons[item_id])
func _on_item_pressed(item_id:String):
	var item_type=GameManager.items[item_id]["type"]
	
	if not GameManager.equipped.has(item_type):
		return
	if GameManager.equipped[item_type]==item_id:
		GameManager.equipped[item_type]=""
		print("unequipped:",GameManager.items[item_id]["name"])
	else:
		GameManager.equip_item(item_id)
	_refresh_inventory() 

func _refresh_crafting():
	for child in crafting_list.get_children():
		child.queue_free()
	for item_id in GameManager.recipes:
		var cost=GameManager.recipes[item_id]
		var item_name=GameManager.items[item_id]["name"]
		var button=Button.new()
		var affordable=GameManager.can_craft(item_id)
		var cost_text = "Timber:" + str(cost["timber"]) + " Fiber:" + str(cost["fiber"]) + " Meat:" + str(cost["meat"])
		button.text=item_name+"("+cost_text+")"
		button.disabled=not affordable
		button.pressed.connect(_on_craft_pressed.bind(item_id))
		crafting_list.add_child(button)
		
func _on_craft_pressed(item_id:String):
	if GameManager.craft_item(item_id):
		print("Crated:",GameManager.items[item_id]["name"])
	_refresh_crafting()
	
func _build_storage_grid():
	for i in range(MAX_STORAGE_SLOTS):
		var slot=INVENTORY_SLOT.instantiate()
		slot.gui_input.connect(_on_slot_input.bind(i))
		storage_grid.add_child(slot)
		storage_slot_nodes.append(slot)
		
func _on_slot_input(event:InputEvent,slot_index:int):
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		print("clicked slot number:",slot_index)

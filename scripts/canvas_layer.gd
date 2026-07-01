extends CanvasLayer

@onready var help_panel:Control=$HelpPanel
@onready var inventory_panel:Control=$InventoryPanel
@onready var inventory_list:VBoxContainer=$InventoryPanel/VBoxContainer
@onready var crafting_panel:Control=$CraftingPanel
@onready var crafting_list:VBoxContainer=$CraftingPanel/VBoxContainer
func _ready():
	help_panel.visible=false
	inventory_panel.visible=false
	crafting_panel.visible=false
func _unhandled_input(event):
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible
	if event.is_action_pressed("toggle_inventory"):
		inventory_panel.visible=!inventory_panel.visible
		if inventory_panel.visible:
			_refresh_inventory()
	if event.is_action_pressed("toggle_crafting"):
		crafting_panel.visible=!crafting_panel.visible
		if crafting_panel.visible:
			_refresh_crafting()

func _refresh_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	for item_id in GameManager.inventory:
		var item_data=GameManager.items[item_id]
		var button=Button.new()
		var prefix=""
		if GameManager.equipped.has(item_data["type"]) and GameManager.equipped[item_data["type"]] == item_id:
			prefix="[Equipped]"
		button.text=prefix+item_data["name"]+"("+item_data["type"]+")"
		button.pressed.connect(_on_item_pressed.bind(item_id))
		inventory_list.add_child(button)
		
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

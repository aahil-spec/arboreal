extends CanvasLayer

@onready var help_panel:Control=$HelpPanel
@onready var inventory_panel:Control=$InventoryPanel
@onready var inventory_list:VBoxContainer=$InventoryPanel/VBoxContainer
func _ready():
	help_panel.visible=false
	inventory_panel.visible=false
func _unhandled_input(event):
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible
	if event.is_action_pressed("toggle_inventory"):
		inventory_panel.visible=!inventory_panel.visible
		if inventory_panel.visible:
			_refresh_inventory()

func _refresh_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	for item_id in GameManager.inventory:
		var item_data=GameManager.items[item_id]
		var button=Button.new()
		var prefix=""
		if GameManager.equipped[item_data["type"]]==item_id:
			prefix="[Equipped]"
		button.text=prefix+item_data["name"]+"("+item_data["type"]+")"
		button.pressed.connect(_on_item_pressed.bind(item_id))
		inventory_list.add_child(button)
		
func _on_item_pressed(item_id:String):
	var item_type=GameManager.items[item_id]["type"]
	if GameManager.equipped[item_type]==item_id:
		GameManager.equipped[item_type]=""
		print("unequipped:",GameManager.items[item_id]["name"])
	else:
		GameManager.equip_item(item_id)
	_refresh_inventory()

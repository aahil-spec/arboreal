extends CanvasLayer



@onready var help_panel:Control=$HelpPanel
@onready var inventory_screen:Panel=$InventoryScreen

func _ready():
	help_panel.visible=false
	inventory_screen.visible=false

func _unhandled_input(event):
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible
	if event.is_action_pressed("toggle_inventory"):
		inventory_screen.visible=!inventory_screen.visible
		
		if inventory_screen.visible:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

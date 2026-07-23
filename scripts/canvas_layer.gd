extends CanvasLayer


@onready var pause_panel:Control=$PausePanel
@onready var help_panel:Control=$HelpPanel
@onready var inventory_screen:Panel=$InventoryScreen

@onready var quest_log:Control=$QuestLogPanel

var is_paused:bool=false

func _ready():
	help_panel.visible=false
	inventory_screen.visible=false
	pause_panel.visible=false
	quest_log.visible=false
func _unhandled_input(event):
	if event.is_action_pressed("toggle_inventory") and not is_paused:
		inventory_screen.visible=!inventory_screen.visible
		if inventory_screen.visible:
			inventory_screen.refresh_all()
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		else:
			_return_held_item()
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible
		
	if event.is_action_pressed("pause"):
		if inventory_screen.visible or quest_log.visible:
			return
		_toggle_pause()
		
	if event.is_action_pressed("toggle_quest_log") and not is_paused:
		quest_log.visible=!quest_log.visible
		if quest_log.visible:
			quest_log.refresh()
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		elif not inventory_screen.visible:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			

func _return_held_item():
	if not inventory_screen.held_item.is_empty():
		GameManager.inventory.append(inventory_screen.held_item)
		inventory_screen.held_item=""
		inventory_screen.held_display.visible=false
		
func _toggle_pause():
	is_paused=!is_paused
	if is_paused:
		pause_panel.show_pause()
	else:
		pause_panel.hide_pause()

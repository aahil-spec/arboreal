extends CanvasLayer

@onready var help_panel:Control=$HelpPanel

func _ready():
	help_panel.visible=false
	
func _unhandled_input(event):
	if event.is_action_pressed("toggle_help"):
		help_panel.visible=!help_panel.visible

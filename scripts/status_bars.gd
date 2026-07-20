extends Control

@onready var health_bar:HBoxContainer=$HealthBar
@onready var thirst_bar:HBoxContainer=$ThirstBar


var heart_full=preload("res://assets/ui/heart_full.png")
var heart_half=preload("res://assets/ui/heart_half.png")
var heart_empty=preload("res://assets/ui/heart_empty.png")

var thirst_full=preload("res://assets/ui/thirst_full.png")
var thirst_half=preload("res://assets/ui/thirst_half.png")
var thirst_empty=preload("res://assets/ui/thirst_empty.png")
const MAX_ICONS:int=10

func _process(_delta):
	_update_bar(health_bar,GameManager.player_health,heart_full,heart_half,heart_empty)
	@warning_ignore("integer_division")
	_update_bar(thirst_bar,int(GameManager.thirst)/5,thirst_full,thirst_half,thirst_empty)
	
	
func _update_bar(container:HBoxContainer,scaled_value:int,tex_full:Texture2D,tex_half:Texture2D,tex_empty:Texture2D):
	for child in container.get_children():
		child.queue_free()
		
		@warning_ignore("integer_division")
		var full_icons=scaled_value/2
		var has_half=scaled_value%2 !=0
		
		for i in range(MAX_ICONS):
			var icon=TextureRect.new()
			icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			if i < full_icons:
				icon.texture=tex_full
			elif i ==full_icons and has_half:
				icon.texture=tex_half
			else:
				icon.texture=tex_empty
			container.add_child(icon)

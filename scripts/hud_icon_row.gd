extends HBoxContainer

@export var full_icon:Texture2D
@export var half_icon:Texture2D
@export var empty_icon:Texture2D
@export var max_icons:int=10
@export var icon_size:Vector2=Vector2(20,20)

var icon_nodes:Array=[]

func _ready():
	_build_icons()
	
func _build_icons():
	for child in get_children():
		child.queue_free()
	icon_nodes.clear()
	
	for i in range(max_icons):
		var tex_rect=TextureRect.new()
		tex_rect.custom_minimum_size=icon_size
		tex_rect.expand_mode=TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture=empty_icon
		add_child(tex_rect)
		icon_nodes.append(tex_rect)
		
func update_value(current:float,maximum:float):
	var filled=(current/maximum)*max_icons
	for i in range(max_icons):
		var icon_node=icon_nodes[i]
		if filled>=i+1.0:
			icon_node.texture=full_icon
		elif filled>=i+0.5:
			icon_node.texture=half_icon
		else:
			icon_node.texture=empty_icon

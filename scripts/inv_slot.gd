extends Panel


signal slot_clicked(index,button)
signal slot_hovered(index)
signal slot_unhovered()

var slot_index:int=-1

var current_has_item:bool=false
var current_is_equipped:bool=false

@onready var count_label=$CountLabel


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(slot_index,event.button_index)
		
func _on_mouse_entered():
	slot_hovered.emit(slot_index)

func _on_mouse_exited():
	slot_unhovered.emit()

func set_slot_state(has_item:bool,is_equipped:bool=false):
	var style=StyleBoxFlat.new()
	style.set_corner_radius_all(3)
	style.content_margin_left=2
	style.content_margin_top=2
	style.content_margin_right=2
	style.content_margin_left=2
	
	if is_equipped:
		style.bg_color=Color(0.18,0.15,0.08)
		style.border_color=Color(1.0,0.82,0.25)
		style.set_border_width_all(2)
	elif has_item:
		style.bg_color=Color(0.16,0.15,0.14)
		style.border_color=Color(0.42,0.38,0.32)
		style.set_border_width_all(1)
	else:
		style.bg_color=Color(0.08,0.075,0.07)
		style.border_color=Color(0.22,0.2,0.18)
		style.set_border_width_all(1)
	add_theme_stylebox_override("panel",style)

@warning_ignore("unused_parameter")
func update_display(item_id:String,count:int):
	if count>1:
		count_label.text=str(count)
		count_label.visible=true
	else:
		count_label.visible=false

func set_craft_hovered(has_item:bool,matches_recipe:bool=false):
	var style=StyleBoxFlat.new()
	style.set_corner_radius_all(3)
	
	if has_item and matches_recipe:
		style.bg_color=Color(0.14,0.18,0.1)
		style.border_color=Color(0.5,0.85,0.35)
		style.set_border_width_all(2)
	elif has_item:
		style.bg_color=Color(0.16,0.15,0.14)
		style.border_color=Color(0.2,0.19,0.22)
		style.set_border_width_all(1)
		
	add_theme_color_override("panel",style)
	
func show_craft_result():
	var tween=create_tween().set_loops(2)
	tween.tween_property(self,"scale",Vector2(1.08,1.08),0.15)
	tween.tween_property(self,"scale",Vector2(1.0,1.0),0.15)
func set_craft_slot_state(has_item:bool,matches_recipe:bool=false):
	var style=StyleBoxFlat.new()
	style.set_corner_radius_all(3)
	
	if has_item and matches_recipe:
		style.bg_color=Color(0.14,0.18,0.1)
		style.border_color=Color(0.5,0.85,0.35)
		style.set_border_width_all(2)
	elif has_item:
		style.bg_color=Color(0.16,0.15,0.14)
		style.border_color=Color(0.42,0.38,0.32)
		style.set_border_width_all(1)
	else:
		style.bg_color=Color(0.07,0.07,0.08)
		style.border_color=Color(0.2,0.19,0.22)
		style.set_border_width_all(1)
	add_theme_stylebox_override("panel",style)

extends Control

const INV_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const HOTBAR_SIZE=9

@onready var container=$HBoxContainer
var hotbar_slots:Array=[]

func _ready():
	_build_hotbar()
	GameManager.hotbar_changed.connect(refresh_hotbar)
	call_deferred("refresh_hotbar")
	
func _build_hotbar():
	for i in range(HOTBAR_SIZE):
		var slot=INV_SLOT.instantiate()
		slot.slot_index=i
		slot.mouse_filter=Control.MOUSE_FILTER_IGNORE
		container.add_child(slot)
		hotbar_slots.append(slot)

func refresh_hotbar():
	for i in range(HOTBAR_SIZE):
		var slot=hotbar_slots[i]
		var icon_node=slot.get_node("Icon")
		var count_label=slot.get_node("CountLabel")
		
		icon_node.texture=null
		count_label.text=""
		_set_slot_border(slot,i==GameManager.active_hotbar_slot)
		
		if i <GameManager.inventory.size():
			var item=GameManager.inventory[i]
			if item is Dictionary and item.has("id"):
				var item_id=item["id"]
				if GameManager.item_icons.has(item_id):
					var path=GameManager.item_icons[item_id]
					if ResourceLoader.exists(path):
						icon_node.texture=load(path)
						
				if item["count"]>1:
					count_label.text=str(item["count"])
					
func _set_slot_border(slot:Panel,active:bool):
	var style=StyleBoxFlat.new()
	style.bg_color=Color(0.22,0.22,0.22,0.8)
	style.set_corner_radius_all(2)
	
	if active:
		style.border_color=Color(1.0,1.0,1.0)
		style.set_border_width_all(3)
	else:
		style.border_color=Color(0.4,0.4,0.4)
		style.set_border_width_all(2)
		
	slot.add_theme_stylebox_override("panel",style)

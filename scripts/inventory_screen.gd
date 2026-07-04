extends Panel

@onready var helmet_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/HelmetSlot
@onready var armor_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/ArmorSlot
@onready var leggings_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/LeftEquip/LeggingsSlot
@onready var boots_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/Bootsslot
@onready var weapon_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/WeaponSlot
@onready var offhand_slot:Panel=$MainLayout/CenterPanel/VBoxContainer/EquipLayout/RightEquip/OffhandSlot

var equip_slot_map:Dictionary={}


const INV_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const CRAFT_SLOT=preload("res://scenes/ui/inv_slot.tscn")
const MAX_INV_SLOTS=48

var inv_slot_nodes:Array=[]
var craft_grid_slots:Array=[]
var craft_output_slot:Panel=null
var held_item:String=""
var held_item_source:String=""
var held_item_source_index:int=-1

@onready var inventory_grid:GridContainer=$MainLayout/LeftPanel/VBoxContainer/InventoryGrid
@onready var tooltip_label:Label=$MainLayout/LeftPanel/VBoxContainer/ToolTipLabel

func _ready():
	_build_inventory_grid()
	_build_equip_slot_map()
	

func _build_inventory_grid():
	for i in range(MAX_INV_SLOTS):
		var slot = INV_SLOT.instantiate()
		slot.slot_index=1
		slot.slot_clicked.connect(_on_inv_slot_clicked)
		slot.slot_hovered.connect(_on_slot_hovered)
		slot.slot_unhovered.connect(_on_slot_unhovered)
		inventory_grid.add_child(slot)
		inv_slot_nodes.append(slot)
@warning_ignore("unused_parameter")
func _on_inv_slot_clicked(index: int, button: int):
	pass
@warning_ignore("unused_parameter")
func _on_slot_hovered(index: int):
	pass
func _on_slot_unhovered():
	pass

func _build_equip_slot_map():
	equip_slot_map={
		"helmet":helmet_slot,
		"armor":armor_slot,
		"leggings":leggings_slot,
		"boots":boots_slot,
		"weapon":weapon_slot,
		"offhand":offhand_slot,
	}
	for slot_type in equip_slot_map:
		var slot_node=equip_slot_map[slot_type]
		slot_node.slot_clicked.connect(_on_equip_slot_clicked.bind(slot_type))
		slot_node.slot_hovered.connect(_on_equip_slot_hovered.bind(slot_type))
		slot_node.slot_unhovered.connect(_on_slot_unhovered

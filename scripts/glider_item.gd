extends Node3D


func equip():
	visible=true
	GameManager.equipped_item="Elytra"
	
func unequip():
	visible=false
	GameManager.equipped_item="None"
